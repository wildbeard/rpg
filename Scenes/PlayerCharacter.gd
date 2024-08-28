class_name PlayerCharacter
extends Character

func _init() -> void:
	characterStats = PlayerStats.new()
	characterStats.baseHp = 75
	isEnemy = false
	# Abilities
	abilityBook = CharacterAbilityBook.new(self)

func _ready() -> void:
	abilityBook.addAbility(abilityBook.getAbility("Slash"))
	abilityBook.addAbility(abilityBook.getAbility("Fireball"))
	abilityBook.addAbility(abilityBook.getAbility("Fire Overload"))
	abilityBook.addAbility(abilityBook.getAbility("Magical Affinity"))
	abilityBook.addAbility(abilityBook.getAbility("Absolute Unit"))
	_setupHealthComponent()

# @todo: Load data from a resource/json file
func _loadPlayerData() -> void:
	pass

func getEquippedItems() -> Dictionary:
	return PlayerManager.getEquippedItems()
