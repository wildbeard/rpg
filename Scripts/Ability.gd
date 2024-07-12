class_name Ability

enum DamageType {
	PHYSICAL,
	MAGICAL,
}

enum AbilityType {
	SINGLE,
	MULTI,
	HEAL,
	HEAL_MULTI,
	SHIELD,
}

const DamageStatType: Dictionary = {
	Strength = "strength",
	Intelligence = "intelligence",
}

const abilities: Array[Dictionary] = [
	{
		"id": 1,
		"name": "Slash",
		"cooldown": 0,
		"ability_type": AbilityType.SINGLE,
		"damage_type": DamageType.PHYSICAL,
		"damage_base": 15,
		"damage_weap_modifier": 0.25,
		"damage_stat_modifier": [0.35],
		"damage_stat_type": ["strength"]
	},
	{
		"id": 2,
		"name": "Weak Slash",
		"cooldown": 0,
		"ability_type": AbilityType.SINGLE,
		"damage_type": DamageType.PHYSICAL,
		"damage_base": 8,
		"damage_weap_modifier": 0.25,
		"damage_stat_modifier": [0.25],
		"damage_stat_type": ["strength"]
	},
	{
		"id": 3,
		"name": "Judgement",
		"cooldown": 1,
		"ability_type": AbilityType.SINGLE,
		"damage_type": DamageType.MAGICAL,
		"damage_base": 20,
		"damage_weap_modifier": 0.25,
		"damage_stat_modifier": [0.25,0.4],
		"damage_stat_type": ["strength", "intelligence"]
	},
	{
		"id": 4,
		"name": "Heal",
		"cooldown": 3,
		"ability_type": AbilityType.HEAL,
		"damage_type": DamageType.MAGICAL,
		"damage_base": 8,
		"damage_weap_modifier": 0.0,
		"damage_stat_modifier": [0.10, 0.8],
		"damage_stat_type": ["intelligence", "wisdom"]
	}
]

var id: int
var name: String
var cooldown: int
var ability_type: AbilityType
var damage_type: DamageType
var damage_base: int
var damage_weap_modifier: float
var damage_stat_modifier: Array
var damage_stat_type: Array

func _init(id: int) -> void:
	# Just trust us bro
	var abils: Array[Dictionary] = self.abilities.filter(func(a: Dictionary): return a.id == id)
	var ability: Dictionary = abils[0]

	for key in ability:
		self[key] = ability[key]

func getAttackDamage(stats: CharacterStats, equipment: Dictionary) -> int:
	var base: int = self.damage_base
	var statMod: float = 0
	var weapMod: float = 0
	var idx: int = 0

	for key in self.damage_stat_type:
		var baseStat: int = stats[key]
		var statBonus: int = stats.getEquipmentAttributes(key) if stats is PlayerStats else 0
		statMod += ((baseStat + statBonus) * self.damage_stat_modifier[idx])

	if stats is PlayerStats:
		weapMod = self.damage_weap_modifier * stats.getPhysicalPower()
	else:
		if equipment.has("mainHand") && equipment.mainHand:
			# @todo: Support off-hand weapon?
			weapMod = (self.damage_weap_modifier * equipment.mainHand.item.damage)
		else:
			# Unarmed
			weapMod = (self.damage_weap_modifier * 5)

	return ceili(base + statMod + weapMod)
