extends Character
class_name Goblin

func _ready() -> void:
	# Stats
	self.characterStats.strength = 10
	self.characterStats.vitality = 1

	# Abilities
	self.abilityBook.addAbility(preload("res://Resources/Abilities/slash.tres"))
	self._setupHealthComponent()
