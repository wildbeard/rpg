class_name PlayerCharacter
extends Character

func _init() -> void:
	self.characterStats = PlayerStats.new()
	self.characterStats.baseHp = 75
	self.isEnemy = false
	# Abilities
	self.abilityBook = CharacterAbilityBook.new(self)

func _ready() -> void:
	self.abilityBook.addAbility(self.abilityBook.getAbility("Slash"))
	self.abilityBook.addAbility(self.abilityBook.getAbility("Fireball"))
	self.abilityBook.addAbility(self.abilityBook.getAbility("Dawn Of A Hundred Blades"))
	self.abilityBook.addAbility(self.abilityBook.getAbility("Fire Overload"))
	self.abilityBook.addAbility(self.abilityBook.getAbility("Magical Affinity"))
	self.abilityBook.addAbility(self.abilityBook.getAbility("Absolute Unit"))
	self._setupHealthComponent()

# @todo: Load data from a resource/json file
func _loadPlayerData() -> void:
	pass

func getEquippedItems() -> Dictionary:
	return PlayerManager.getEquippedItems()
