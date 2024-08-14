extends Character
class_name GoblinWizard

func _ready() -> void:
	# Stats
	self.characterStats.wisdom = 10
	self.characterStats.intelligence = 5
	self.characterStats.vitality = 1

	# Abilities
	self.abilityBook.addAbility(preload("res://Resources/Abilities/fireball.tres"))
	self._setupHealthComponent()
