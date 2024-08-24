extends Node2D
class_name HealthComponent

signal no_health
signal health_changed(value: int)

@export var max_health: int = 3:
	get:
		return max_health
	set(val):
		max_health = max(1, val)

@export var health: int = max_health:
	get:
		return health
	set(val):
		health = clamp(val, 0, max_health)
		health_changed.emit(val)

		# Can we just use health_changed and check in parent?
		if health <= 0:
			no_health.emit()

func _ready() -> void:
	health = max_health

func takeDamage(dmg: int) -> void:
	health -= dmg

func heal(val: int) -> void:
	health = clamp(health + val, health, max_health)
