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
}

func _ready() -> void:
	call_deferred("_setup")

func _setup() -> void:
	self._setupPlayer()
	self._setupEnemies()
	%TargetIndicator.enemies = self.enemies
	self._generateTurnOrder()
	self._startRound()

func _setupPlayer() -> void:
	var character: PlayerCharacter = PlayerManager.player
	character.global_position = %PlayerMarker.global_position

	# @todo: A better way?
	if !PlayerManager.stats.is_connected("levelUp", self._handlePlayerLevelUp):
		PlayerManager.stats.connect("levelUp", self._handlePlayerLevelUp)

	self.player = character
	add_child(character)

func _handlePlayerLevelUp() -> void:
	var scene: LevelUpScene = self.levelUpScene.instantiate()
	self.levelUp = scene
	self.isLevelingUp = true

	add_child(scene)
	get_tree().paused = true
	self._print("Player is now level %d!" % PlayerManager.stats.level)
	var levelUpdates: Dictionary = await scene.confirm_choices

	for key in levelUpdates.stats:
		print("Setting %s to %d" % [key, levelUpdates.stats[key]])
		PlayerManager.stats[key] = levelUpdates.stats[key]

	PlayerManager.getAbilityBook().addAbility(levelUpdates.ability)
	remove_child(scene)
	get_tree().paused = false
	self.levelUp = null
	self.isLevelingUp = false

func _setupEnemies() -> void:
	print(self.enemies.size())
	if !self.enemies.size():
		for e in 3:
			var enemy: Enemy

			if randi_range(0, 1) == 0:
				enemy = preload("res://Scenes/Enemies/GoblinWizard.tscn").instantiate()
			else:
				enemy = preload("res://Scenes/Enemies/Goblin.tscn").instantiate()

			self.enemies.push_back(enemy)

	for e in self.enemies.size():
		var enemy: Character = self.enemies[e]
		var enemyPos: Vector2 = %EnemyMarker.global_position
		enemyPos.y = enemyPos.y + (e * 42)
		enemy.global_position = enemyPos

		add_child(enemy)
		# Allows us to detect hover/click with the color rect in the BG
		# Using z_index or top_level does not work
		move_child(enemy, -1)

func _generateTurnOrder() -> void:
	# @todo: Player is currently always first.
	self.turnOrder.push_back(self.player)
	
	for e in self.enemies:
		self.turnOrder.push_back(e)

func _startRound() -> void:
	var attacker := self.turnOrder[self.currentTurn]
	%Round.text = "Round: %d" % self.currentRound
	%CharacterTurn.text = "Character Turn: %d" % self.currentTurn

	if !attacker.isEnemy:
		self._playerTurn()
	else:
		self._enemyTurn(attacker)

func _playerTurn() -> void:
	self._print("It is the Player's turn!")
	var abilities: Array[Ability] = self.player.abilityBook.getActiveAbilities()
	var onCooldown: Array[String]

	for ability in abilities:
		if self.player.abilityBook.isAbilityOnCooldown(ability.name, self.currentRound):
			onCooldown.push_back(ability.name)

	%AbilitySelector.setAbilities(abilities)
	%AbilitySelector.updateCooldowns(onCooldown)
	%AbilitySelector.visible = true
	"""
		If I use queue_free() in Character:_on_no_health() then this array
		returns empty _even if_ there are remaining enemies. What gives?
	"""
	var availTargets := self.enemies.filter(func(c: Character): return !c.isDead)

	if availTargets.size() == 0:
		return self._endBattle(false)

	var idx: int = availTargets.find(availTargets[0])
	
	if idx == -1:
		# ???
		return self._endBattle(false)

	var abilityId = await %AbilitySelector.ability_selected
	%AbilitySelector.visible = false

	var ability: Ability = self.player.abilityBook.getAbility(abilityId)

	if self.player.abilityBook.isAbilityOnCooldown(abilityId, self.currentRound):
		push_error("%s is on cooldown and shouldn't be available." % ability.name)
		return self._endTurn()

	if ability.ability_type == Ability.TargetType.HEAL:
		var hits: Array[int] = self.player.abilityBook.useAbility(ability)

		for val in hits:
			self.player.getHealed(val)
			self.battleStats.damage_healed += val
			self._print("Player uses ability %s and heals self for %d" % [ability.name, val])
	else:
		%TargetIndicator.visible = true
		%TargetIndicator.hoverTarget(idx)
		var target: Character = await %TargetIndicator.target_selected
		%TargetIndicator.visible = false

		var hits: Array[int] = self.player.abilityBook.useAbility(ability)

		for hit in hits:
			var dmg: int = target.mitigateDamage(hit, ability.damage_type)
			var mitigated: int = hit - dmg

			self._print("Player uses ability %s. Target's armor mitigates %d and hits for %d" % [ability.name, mitigated, dmg])
			self.battleStats.damage_dealt += dmg
			target.getHit(dmg)

			if self.battleStats.highest_hit < dmg:
				self.battleStats.highest_hit = dmg

		if target.isDead:
			remove_child(target)
			self.battleStats.xp_gained += target.characterStats.xpGiven
			player.characterStats.currentXp += target.characterStats.xpGiven

	if ability.cooldown:
		self.player.abilityBook.updateAbilityCooldown(abilityId, self.currentRound + ability.cooldown)

	# @TODO: Feelsbadman
	if self.isLevelingUp:
		await self.levelUp.confirm_choices

	self._endTurn()

func _enemyTurn(attacker: Character) -> void:
	# @todo: Pick from turn order and get a player
	var target: Character = self.player
	var ability: Ability = attacker.abilityBook.getActiveAbilities().pick_random()

	# :) Nice bug
	if !ability:
		self._endTurn()

	# @todo: Fix this still has a chance the ability is on cooldown
	if attacker.abilityBook.isAbilityOnCooldown(ability.name, self.currentRound):
		ability = attacker.abilityBook.getActiveAbilities().filter(func(a: Ability): return a != ability).pick_random()

	self._print("It is the enemies turn!")
	var hits: Array[int] = attacker.abilityBook.useAbility(ability)

	for hit in hits:
		var dmg: int = target.mitigateDamage(hit, ability.damage_type)
		var mitigate: int = hit - dmg
		self.battleStats.damage_taken += dmg

		self._print("Enemy uses ability %s. Target's armor mitigates %d and hits for for %d" % [ability.name, mitigate, dmg])
		target.getHit(dmg)

	if target.isDead:
		return self._endBattle(true)

	await get_tree().create_timer(2).timeout
	self._endTurn()

func _endTurn() -> void:
	if self.currentTurn + 1 > self.turnOrder.size()-1:
		self._endRound()
		return

	self.currentTurn += 1
	var attacker: Character = self.turnOrder[self.currentTurn]

	if attacker.isEnemy && attacker.isDead:
		return self._endTurn()

	%CharacterTurn.text = "Character Turn: %d" % self.currentTurn

	if attacker.isEnemy:
		self._enemyTurn(attacker)
	else:
		self._playerTurn()

func _endRound() -> void:
	self.currentRound += 1
	self.currentTurn = 0
	self._startRound()

func _endBattle(didPlayerDie: bool) -> void:
	if didPlayerDie:
		self._print("You Died.")
	else:
		var scn: EndBattleModal = self.endBattleScene.instantiate()
		self.battleStats.xp_remaining = PlayerManager.stats.xpRemaining
		scn.battleStats = self.battleStats
		scn.connect("restart", self._on_resart)
		%CombatText.text = ""
		add_child(scn)

func _on_resart() -> void:
	self.player.abilityBook.resetCooldowns()
	self.remove_child(self.player)
	self.switch_scene.emit(self.overworld.instantiate())

func _print(txt: String) -> void:
	%CombatText.text = %CombatText.text + "\n%s" % txt
