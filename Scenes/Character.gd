extends StaticBody2D
class_name Character

@export var healthComponent: HealthComponent
@export var characterStats: CharacterStats
@export var isInBattle: bool = true
@export var isEnemy: bool = true

var isDead: bool = false
var abilityBook: CharacterAbilityBook

func _ready() -> void:
	self.healthComponent.connect("no_health", _on_no_health)
	self.healthComponent.connect("health_changed", _on_health_change)

	%HPBar.max_value = self.healthComponent.max_health
	%HPBar.value = self.healthComponent.max_health

func getHit(dmg: int) -> void:
	self.healthComponent.takeDamage(dmg)

func _on_health_change(health: int) -> void:
	%HPBar.value = health

func _on_no_health() -> void:
	self.isDead = true
	"""
		If I use queue_free() here, BattleScene:_playerTurn()'s check for alive
		enemies always returns an empty array even if there are enemies still alive.
	"""
	# queue_free()
