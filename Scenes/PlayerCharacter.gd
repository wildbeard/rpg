class_name PlayerCharacter
extends Character

func _init() -> void:
	self.characterStats = PlayerManager.stats
	self.characterStats.baseHp = 75
	self.isEnemy = false
	# Abilities
	self.abilityBook = CharacterAbilityBook.new(self)
	self.abilityBook.addAbility(Ability.new(2))

func getEquippedItems() -> Dictionary:
	return PlayerManager.getEquippedItems()
