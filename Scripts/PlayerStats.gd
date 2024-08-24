class_name PlayerStats
extends CharacterStats

signal levelUp()

var currentXp: int = 0:
	set(val):
		if currentXp + val > xpRequired:
			currentXp = 0
			level += 1
			levelUp.emit()
		else:
			currentXp += val

var xpRequired: int:
	get:
		# @todo: Pretty Simple
		return level * 100
var xpRemaining: int:
	get:
		return xpRequired - currentXp

func getPhysicalPower() -> int:
	return _getEquipmentStats(true, false) + getAdjustedStat("strength")

func getPhysicalDef() -> int:
	return _getEquipmentStats(true, true) + ceili(getAdjustedStat("strength") * 0.75)

func getMagicalPower() -> int:
	return _getEquipmentStats(false, false) + getAdjustedStat("intelligence")

func getMagicalDef() -> int:
	return _getEquipmentStats(false, true) + ceili(getAdjustedStat("intelligence") * 0.75)

func _getEquipmentStats(isPhysical: bool, isDef: bool) -> int:
	var rating: int = 0
	var equipment: Dictionary = PlayerManager.getEquippedItems()

	for key in equipment:
		var item: Equipment = equipment[key].item if equipment[key] else null

		if !item:
			continue

		if isDef && item is Armor:
			if isPhysical:
				rating += item.physicalDefense
			else:
				rating += item.magicalDefense
		elif !isDef && item is Weapon:
			if isPhysical:
				rating += item.physicalDamage
			else:
				rating += item.magicalDamage

	return rating

