extends Enemy
class_name GoblinWizard

@onready var area2D: Area2D = $Area2D

func _ready() -> void:
	# Stats
	self.characterStats.wisdom = 10
	self.characterStats.intelligence = 5
	self.characterStats.vitality = 1

	# Abilities
	self.abilityBook.addAbility(preload("res://Resources/Abilities/fireball.tres"))
	self._setupHealthComponent()
	
	self.area2D.body_entered.connect(self._on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is OverworldPlayer:
		var enemies: Array[Enemy] = [self]
		self.start_battle.emit(enemies)
