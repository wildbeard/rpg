class_name CharacterAbilityBook

var _abilities: Dictionary
var _cooldowns: Dictionary
var _player: Character
var _allAbilities: Dictionary

func _init(player: Character) -> void:
	self._player = player

	for file in DirAccess.get_files_at("res://Resources/Abilities/"):
		var filePath: String = "res://Resources/Abilities/" + file.replace(".import", "")
		var ability: Ability = load(filePath) as Ability
		self._allAbilities[ability.name] = ability

# @todo: I think ideally abilities are loaded from somewhere but this
# should work for now.
func addAbility(ability: Ability) -> void:
	self._abilities[ability.name] = ability

func getAbility(name: String) -> Ability:
	return self._allAbilities[name]

func getActiveAbilities() -> Array[Ability]:
	return self.getAbilities([Ability.AbilityType.ACTIVE])

func getPassiveAbilities() -> Array[Ability]:
	return self.getAbilities([Ability.AbilityType.PASSIVE])

func getDefensivePassives() -> Array[Ability]:
	return self.getAbilities([Ability.AbilityType.PASSIVE_DEFENSE])

func getAbilities(abilityTypes: Array[Ability.AbilityType]) -> Array[Ability]:
	var a: Array[Ability] = []

	for name in self._abilities:
		var abilityType: Ability.AbilityType = self._abilities[name].ability_type
		if abilityTypes.has(abilityType):
			a.push_back(self._abilities[name])

	return a

func isAbilityOnCooldown(name: String, currRound: int) -> bool:
	# @todo: Support cooldown reduction?
	return self._cooldowns.has(name) && self._cooldowns[name] >= currRound

func updateAbilityCooldown(name: String, tillRound: int) -> void:
	self._cooldowns[name] = tillRound

# Returns the pre-mitigation damage or 0 if unavailable
func useAbility(ability: Ability) -> Array[int]:
	if !self._abilities.has(ability.name):
		# ???
		return [0]
	
	var hits: Array[int] = []

	for i in ability.number_of_hits:
		var dmg: int = ability.getAttackDamage(self._player.characterStats, self._player.getEquippedItems())
		var bonusDmg: float = 0
		"""
			This allows passives to apply to a specific element type
			or to a general damage type.
			We can do a form of rudimentary "stacking" by simply adding more of the same
			passive ability to their passive list.
		"""
		var passives: Array[Ability] = self.getPassiveAbilities()\
			.filter(func(a: Ability): \
				return a.element_type == ability.element_type \
					|| (a.element_type == Ability.ElementType.NONE && a.damage_type == ability.damage_type)
				)

		# @todo: This isn't very well thought out and will need to be re-done
		for passive in passives:
			for modifier in passive.damage_stat_modifier:
					bonusDmg += (dmg * (modifier/100))
		
		hits.push_back(dmg + roundi(bonusDmg))

	return hits
