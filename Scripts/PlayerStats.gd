class_name PlayerStats
extends CharacterStats

signal levelUp()

var currentXp: int = 0:
	set(val):
		if currentXp + val > self.xpRequired:
			currentXp = 0
			self.level += 1
			self.levelUp.emit()
		else:
			currentXp += val

var xpRequired: int:
	get:
		# @todo: Pretty Simple
		return self.level * 100
var xpRemaining: int:
	get:
		return self.xpRequired - self.currentXp

func getPhysicalPower() -> int:
	return self._getEquipmentStats(true, false)

func getPhysicalDef() -> int:
	return self._getEquipmentStats(true, true)

func getMagicalPower() -> int:
	return self._getEquipmentStats(false, false)

func getMagicalDef() -> int:
	return self._getEquipmentStats(false, true)

func getEquipmentAttributes(stat: String) -> int:
	var bonus: int = 0
	var equipment: Dictionary = PlayerManager.getEquippedItems()

	for key in equipment:
		var item: Equipment = equipment[key].item if equipment[key] else null

		if !item:
			continue

		bonus += item.statModifiers[stat]

	return bonus

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
