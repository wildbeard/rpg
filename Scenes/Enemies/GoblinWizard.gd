extends Enemy
class_name GoblinWizard

@onready var area2D: Area2D = $Area2D

func _ready() -> void:
	# Stats
	characterStats.wisdom = 10
	characterStats.intelligence = 5
	characterStats.vitality = 1

	# Abilities
	abilityBook.addAbility(preload("res://Resources/Abilities/fireball.tres"))
	_setupHealthComponent()
	
	area2D.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is OverworldPlayer:
		var enemies: Array[Enemy] = [self]
		start_battle.emit(enemies)
