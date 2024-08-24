extends Node2D
class_name BattleScene

signal switch_scene(scene: Node2D)

@export var player: Character
@export var enemies: Array[Enemy]

# DO NOT PRELOAD OVERWORLD
# Causes the scene to act as if it were corrupt
# See: https://github.com/godotengine/godot/issues/70985
var overworld: PackedScene = load("res://Scenes/Overworld.tscn")
var endBattleScene: PackedScene = preload("res://Scenes/UI/EndBattleModal.tscn")
var levelUpScene: PackedScene = preload("res://Scenes/UI/LevelUp.tscn")
var characterScene: PackedScene = preload("res://Scenes/Character.tscn")
var playerScene: PackedScene = preload("res://Scenes/PlayerCharacter.tscn")
var turnOrder: Array[Character]
var currentTurn: int = 0
var currentRound: int = 1

var targetIndex: int = 0
var currentTarget: Character = null
var isLevelingUp: bool = false
var levelUp: LevelUpScene = null

var battleStats: Dictionary = {
	"damage_taken": 0,
	"damage_dealt": 0,
	"damage_healed": 0,
	"highest_hit": 0,
	"xp_gained": 0,
	"xp_remaining": 0,
	"enemies_killed": 0,
	"gold_earned": 0,
	"item_rewards": [],
}

func _ready() -> void:
	call_deferred("_setup")

func _setup() -> void:
	_setupPlayer()
	_setupEnemies()
	%TargetIndicator.enemies = enemies
	_generateTurnOrder()
	_startRound()

func _setupPlayer() -> void:
	var character: PlayerCharacter = PlayerManager.player
	character.global_position = %PlayerMarker.global_position

	# @todo: A better way?
	if !PlayerManager.stats.is_connected("levelUp", _handlePlayerLevelUp):
		PlayerManager.stats.connect("levelUp", _handlePlayerLevelUp)

	player = character
	add_child(character)

func _handlePlayerLevelUp() -> void:
	var scene: LevelUpScene = levelUpScene.instantiate()
	levelUp = scene
	isLevelingUp = true

	add_child(scene)
	get_tree().paused = true
	_print("Player is now level %d!" % PlayerManager.stats.level)
	var levelUpdates: Dictionary = await scene.confirm_choices

	for key in levelUpdates.stats:
		print("Setting %s to %d" % [key, levelUpdates.stats[key]])
		PlayerManager.stats[key] = levelUpdates.stats[key]

	PlayerManager.getAbilityBook().addAbility(levelUpdates.ability)
	remove_child(scene)
	get_tree().paused = false
	levelUp = null
	isLevelingUp = false

func _setupEnemies() -> void:
	print(enemies.size())
	if !enemies.size():
		for e in 3:
			var enemy: Enemy

			if randi_range(0, 1) == 0:
				enemy = preload("res://Scenes/Enemies/GoblinWizard.tscn").instantiate()
			else:
				enemy = preload("res://Scenes/Enemies/Goblin.tscn").instantiate()

			enemies.push_back(enemy)

	for e in enemies.size():
		var enemy: Character = enemies[e]
		var enemyPos: Vector2 = %EnemyMarker.global_position
		enemyPos.y = enemyPos.y + (e * 42)
		enemy.global_position = enemyPos

		add_child(enemy)
		# Allows us to detect hover/click with the color rect in the BG
		# Using z_index or top_level does not work
		move_child(enemy, -1)

func _generateTurnOrder() -> void:
	# @todo: Player is currently always first.
	turnOrder.push_back(player)
	
	for e in enemies:
		turnOrder.push_back(e)

func _startRound() -> void:
	var attacker := turnOrder[currentTurn]
	%Round.text = "Round: %d" % currentRound
	%CharacterTurn.text = "Character Turn: %d" % currentTurn

	if !attacker.isEnemy:
		_playerTurn()
	else:
		_enemyTurn(attacker)

func _playerTurn() -> void:
	_print("It is the Player's turn!")
	var abilities: Array[Ability] = player.abilityBook.getActiveAbilities()
	var onCooldown: Array[String]

	for ability in abilities:
		if player.abilityBook.isAbilityOnCooldown(ability.name, currentRound):
			onCooldown.push_back(ability.name)

	%AbilitySelector.setAbilities(abilities)
	%AbilitySelector.updateCooldowns(onCooldown)
	%AbilitySelector.visible = true
	"""
		If I use queue_free() in Character:_on_no_health() then this array
		returns empty _even if_ there are remaining enemies. What gives?
	"""
	var availTargets := enemies.filter(func(c: Character): return !c.isDead)

	if availTargets.size() == 0:
		return _endBattle(false)

	var idx: int = availTargets.find(availTargets[0])
	
	if idx == -1:
		# ???
		return _endBattle(false)

	var abilityId = await %AbilitySelector.ability_selected
	%AbilitySelector.visible = false

	var ability: Ability = player.abilityBook.getAbility(abilityId)

	if player.abilityBook.isAbilityOnCooldown(abilityId, currentRound):
		push_error("%s is on cooldown and shouldn't be available." % ability.name)
		return _endTurn()

	if ability.ability_type == Ability.TargetType.HEAL:
		var hits: Array[int] = player.abilityBook.useAbility(ability)

		for val in hits:
			player.getHealed(val)
			battleStats.damage_healed += val
			_print("Player uses ability %s and heals self for %d" % [ability.name, val])
	else:
		%TargetIndicator.visible = true
		%TargetIndicator.hoverTarget(idx)
		var target: Character = await %TargetIndicator.target_selected
		%TargetIndicator.visible = false

		var hits: Array[int] = player.abilityBook.useAbility(ability)

		for hit in hits:
			var dmg: int = target.mitigateDamage(hit, ability.damage_type)
			var mitigated: int = hit - dmg

			_print("Player uses ability %s. Target's armor mitigates %d and hits for %d" % [ability.name, mitigated, dmg])
			battleStats.damage_dealt += dmg
			target.getHit(dmg)

			if battleStats.highest_hit < dmg:
				battleStats.highest_hit = dmg

		if target.isDead:
			var rewards: Dictionary = target.generateRewards()
			battleStats.gold_earned += rewards.gold
			battleStats.item_rewards.push_back(rewards.item)
			battleStats.enemies_killed += 1
			battleStats.xp_gained += target.characterStats.xpGiven
			player.characterStats.currentXp += target.characterStats.xpGiven
			remove_child(target)

	if ability.cooldown:
		player.abilityBook.updateAbilityCooldown(abilityId, currentRound + ability.cooldown)

	# @TODO: Feelsbadman
	if isLevelingUp:
		await levelUp.confirm_choices

	_endTurn()

func _enemyTurn(attacker: Character) -> void:
	# @todo: Pick from turn order and get a player
	var target: Character = player
	var ability: Ability = attacker.abilityBook.getActiveAbilities().pick_random()

	# :) Nice bug
	if !ability:
		_endTurn()

	# @todo: Fix this still has a chance the ability is on cooldown
	if attacker.abilityBook.isAbilityOnCooldown(ability.name, currentRound):
		ability = attacker.abilityBook.getActiveAbilities().filter(func(a: Ability): return a != ability).pick_random()

	_print("It is the enemies turn!")
	var hits: Array[int] = attacker.abilityBook.useAbility(ability)

	for hit in hits:
		var dmg: int = target.mitigateDamage(hit, ability.damage_type)
		var mitigate: int = hit - dmg
		battleStats.damage_taken += dmg

		_print("Enemy uses ability %s. Target's armor mitigates %d and hits for for %d" % [ability.name, mitigate, dmg])
		target.getHit(dmg)

	if target.isDead:
		return _endBattle(true)

	await get_tree().create_timer(2).timeout
	_endTurn()

func _endTurn() -> void:
	if currentTurn + 1 > turnOrder.size()-1:
		_endRound()
		return

	currentTurn += 1
	var attacker: Character = turnOrder[currentTurn]

	if attacker.isEnemy && attacker.isDead:
		return _endTurn()

	%CharacterTurn.text = "Character Turn: %d" % currentTurn

	if attacker.isEnemy:
		_enemyTurn(attacker)
	else:
		_playerTurn()

func _endRound() -> void:
	currentRound += 1
	currentTurn = 0
	_startRound()

func _endBattle(didPlayerDie: bool) -> void:
	if didPlayerDie:
		_print("You Died.")
	else:
		var scn: EndBattleModal = endBattleScene.instantiate()
		battleStats.xp_remaining = PlayerManager.stats.xpRemaining
		scn.battleStats = battleStats
		scn.connect("restart", _on_resart)
		%CombatText.text = ""
		add_child(scn)

func _on_resart() -> void:
	player.abilityBook.resetCooldowns()
	remove_child(player)
	switch_scene.emit(overworld.instantiate())

func _print(txt: String) -> void:
	%CombatText.text = %CombatText.text + "\n%s" % txt
