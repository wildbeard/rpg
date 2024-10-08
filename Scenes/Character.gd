extends StaticBody2D
class_name Character

@export var healthComponent: HealthComponent
@export var isInBattle: bool = true
@export var isEnemy: bool = true
@export var inventory: InventoryData

var isDead: bool = false
var abilityBook: CharacterAbilityBook
var characterStats: CharacterStats

func _init() -> void:
	characterStats = CharacterStats.new()
	abilityBook = CharacterAbilityBook.new(self)

func _setupHealthComponent() -> void:
	healthComponent.connect("no_health", _on_no_health)
	healthComponent.connect("health_changed", _on_health_change)
	healthComponent.max_health = characterStats.maxHp
	healthComponent.health = characterStats.maxHp

	%HPBar.max_value = healthComponent.max_health
	%HPBar.value = healthComponent.max_health

func getHit(dmg: int) -> void:
	healthComponent.takeDamage(dmg)

func getHealed(amount: int) -> void:
	healthComponent.heal(amount)

func mitigateDamage(incoming: int, damageType: Ability.DamageType) -> int:
	var equipment: Dictionary = getEquippedItems()
	var passives: Array[Ability] = abilityBook.getDefensivePassives()
	var dmg: int = incoming
	var totalDef: float = 0
	var outgoingDmg: float = 0

	for key in equipment:
		var item = equipment[key]

		# @todo: This is not the way
		if item is SlotData:
			item = item.item

		if item is Armor:
			totalDef += item.getDamageReduction(damageType == Ability.DamageType.PHYSICAL)

	outgoingDmg = (dmg - (dmg * totalDef))

	for passive in passives:
		if passive.damage_stat_type.has(damageType):
			var key: int = passive.damage_stat_type.find(damageType)

			if key >= 0:
				outgoingDmg -= (outgoingDmg * (passive.damage_stat_modifier[key] / 100))
	
	return floori(outgoingDmg)

func _on_health_change(health: int) -> void:
	%HPBar.value = health

func _on_no_health() -> void:
	isDead = true
	"""
		If I use queue_free() here, BattleScene:_playerTurn()'s check for alive
		enemies always returns an empty array even if there are enemies still alive.
	"""
	# queue_free()

# levelDiff: Will be positive if defender is a higher level
func getDodgeChance(dmgType: Ability.DamageType, levelDiff: int) -> float:
	"""
		@todo: Going to use a small % of your relevant stats to increase your dodge
		chance + dex value. This may end up biting me in the ass. Who knows. The 
		idea is that you can still *sort of* dodge even if you're not going into
		dex or speed.
	"""
	var chance: float = 1.0

	# @todo: Obviously not the final numbers
	if dmgType == Ability.DamageType.PHYSICAL:
		chance += characterStats.strength * 0.35
		chance += 2 + (characterStats.dexterity * 0.5)
		chance += characterStats.speed * 0.05
	else:
		chance += characterStats.intelligence * 0.35
		chance += 2 + (characterStats.dexterity * 0.5)
		chance += characterStats.speed * 0.05

	return chance + (levelDiff * 0.25)

# levelDiff: Will be positive if attacker is a higher level
func getHitChance(dmgType: Ability.DamageType, levelDiff: int) -> float:
	var chance: float = 1.0

	# @todo: Obviously not the final numbers
	if dmgType == Ability.DamageType.PHYSICAL:
		chance += characterStats.strength * 1.3
	else:
		chance += characterStats.intelligence * 1.3

	return chance + (levelDiff * 0.5)

func getEquippedItems() -> Dictionary:
	return inventory.equipment
