class_name CharacterAbilityBook

var _abilityResourceList: ResourceList = preload("res://Resources/Abilities.tres")
var _abilities: Dictionary
var _cooldowns: Dictionary
var _player: Character
var _allAbilities: Dictionary

func _init(player: Character) -> void:
	_player = player

	if !_abilityResourceList.is_connected("resource_loaded", _setupAbilities):
		_abilityResourceList.connect("resource_loaded", _setupAbilities)

func _setupAbilities(list: Array) -> void:
	for ability in list as Array[Ability]:
		_allAbilities[ability.name] = ability

# @todo: I think ideally abilities are loaded from somewhere but this
# should work for now.
func addAbility(ability: Ability) -> void:
	_abilities[ability.name] = ability

func getAbility(name: String) -> Ability:
	if !_allAbilities.has(name):
		push_error("Ability (%s) not found" % name)
		return

	return _allAbilities[name]

func getActiveAbilities() -> Array[Ability]:
	return getAbilities([Ability.AbilityType.ACTIVE])

func getPassiveAbilities() -> Array[Ability]:
	return getAbilities([Ability.AbilityType.PASSIVE])

func getDefensivePassives() -> Array[Ability]:
	return getAbilities([Ability.AbilityType.PASSIVE_DEFENSE])

func getAbilities(abilityTypes: Array[Ability.AbilityType]) -> Array[Ability]:
	var a: Array[Ability] = []

	for name in _abilities:
		var abilityType: Ability.AbilityType = _abilities[name].ability_type
		if abilityTypes.has(abilityType):
			a.push_back(_abilities[name])

	return a

func isAbilityOnCooldown(name: String, currRound: int) -> bool:
	# @todo: Support cooldown reduction?
	return _cooldowns.has(name) && _cooldowns[name] >= currRound

func updateAbilityCooldown(name: String, tillRound: int) -> void:
	_cooldowns[name] = tillRound

func resetCooldowns() -> void:
	_cooldowns = {}

# Returns the pre-mitigation damage or 0 if unavailable
func useAbility(ability: Ability) -> Array[int]:
	if !_abilities.has(ability.name):
		# ???
		return [0]
	
	var hits: Array[int] = []

	for i in ability.number_of_hits:
		var dmg: int = ability.getAttackDamage(_player.characterStats, _player.getEquippedItems())
		var bonusDmg: float = 0
		"""
			This allows passives to apply to a specific element type
			or to a general damage type.
			We can do a form of rudimentary "stacking" by simply adding more of the same
			passive ability to their passive list.
		"""
		var passives: Array[Ability] = getPassiveAbilities()\
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
