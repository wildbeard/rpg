class_name PlayerCharacter
extends Character

func _init() -> void:
	print("Player is init")
	self.characterStats = GlobalPlayerStats
	self.characterStats.baseHp = 75
	self.isEnemy = false
	# Abilities
	self.abilityBook = CharacterAbilityBook.new(self)
	self.abilityBook.addAbility(Ability.new(2))

