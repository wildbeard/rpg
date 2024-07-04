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
