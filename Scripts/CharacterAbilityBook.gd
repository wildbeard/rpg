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
	return self.getAbilities(Ability.AbilityType.ACTIVE)

func getPassiveAbilities() -> Array[Ability]:
	return self.getAbilities(Ability.AbilityType.PASSIVE)

func getAbilities(abilityType: Ability.AbilityType) -> Array[Ability]:
	var a: Array[Ability] = []

	for name in self._abilities:
		if self._abilities[name].ability_type == abilityType:
			a.push_back(self._abilities[name])

	return a

func isAbilityOnCooldown(name: String, currRound: int) -> bool:
	# @todo: Support cooldown reduction?
	return self._cooldowns.has(name) && self._cooldowns[name] >= currRound

# Returns the pre-mitigation damage or 0 if unavailable
func useAbility(ability: Ability, currRound: int) -> int:
	if !self._abilities.has(ability.name):
		# ???
		return 0

	var dmg: int = ability.getAttackDamage(self._player.characterStats, self._player.getEquippedItems())
	var bonusDmg: float = 0
	var passives: Array[Ability] = self.getPassiveAbilities()

	# @todo: This isn't very well thought out and will need to be re-done
	if passives.size():
		print(dmg)
		var applicable: Array[Ability] = passives.filter(func(a: Ability): return a.element_type == ability.element_type)

		for a in applicable:
			for modifier in a.damage_stat_modifier:
				bonusDmg += (dmg * (modifier/100))

	if ability.cooldown:
		self._cooldowns[ability.name] = currRound + ability.cooldown

	return dmg + roundi(bonusDmg)
