extends Node
class_name CharacterStats

@export var baseHp: int = 10
@export var baseMp: int = 100
@export var level: int = 1
@export var xpGiven: int:
	get:
		return level * 150

# 10 * level HP + stats
var maxHp: int = baseHp:
	get:
		# @todo: Make vitality less useful as it is levelled
		var fromStats: int = ceili(vitality * 1)
		var fromLevels: int = (0 if level == 1 else 10) * (level - 1)
		return baseHp + fromStats + fromLevels

var strength: int = 5
var intelligence: int = 5
var wisdom: int = 5
var dexterity: int = 5
var speed: int = 5 # Speed
var vitality: int = 10 # HP

func getPhysicalPower() -> int:
	return strength

func getPhysicalDef() -> int:
	return ceili(strength * 0.75)

func getMagicalPower() -> int:
	return intelligence

func getMagicalDef() -> int:
	return ceili(intelligence * 0.75)

func getAdjustedStat(stat: String) -> int:
	return getEquipmentAttributes(stat) + self[stat]

func getEquipmentAttributes(stat: String) -> int:
	var bonus: int = 0
	var equipment: Dictionary = PlayerManager.getEquippedItems()

	for key in equipment:
		var item: Equipment = equipment[key].item if equipment[key] else null

		if !item:
			continue

		bonus += item.statModifiers[stat]

	return bonus
