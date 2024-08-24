extends Enemy
class_name Goblin

func _ready() -> void:
	# Stats
	characterStats.strength = 10
	characterStats.vitality = 1

	# Abilities
	abilityBook.addAbility(preload("res://Resources/Abilities/slash.tres"))
	_setupHealthComponent()
