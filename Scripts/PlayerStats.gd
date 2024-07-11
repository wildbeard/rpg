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

func getAttackPower() -> int:
	var equipment: Dictionary = PlayerManager.getEquippedItems()

	if equipment.has("mainHand") && equipment.mainHand:
		return equipment.mainHand.item.damage

	return 0

func getArmorRating() -> int:
	var equipment: Dictionary = PlayerManager.getEquippedItems()
	var rating: int = 0

	for key in equipment:
		if key == "mainHand" || key == "offHand":
			continue
		if equipment[key]:
			rating += equipment[key].item.armorValue

	return rating
