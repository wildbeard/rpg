class_name CharacterAbilityBook

var _abilities: Dictionary
var _cooldowns: Dictionary
var _player: Character

func _init(player: Character) -> void:
	self._player = player

# @todo: I think ideally abilities are loaded from somewhere but this
# should work for now.
func addAbility(ability: Ability) -> void:
	self._abilities[ability.id] = ability

func getAbilities() -> Array[Ability]:
	var a: Array[Ability] = []

	for id in self._abilities:
		a.push_back(self._abilities[id])

	return a

func isAbilityOnCooldown(id: int, currRound: int) -> bool:
	# @todo: Support cooldown reduction?
	return self.cooldowns.has(id) && self.cooldowns[id] <= currRound

# Returns the pre-mitigation damage or 0 if unavailable
func useAbility(id: int, currRound: int) -> int:
	if !self._abilities.has(id):
		# ???
		return 0

	var ability: Ability = self._abilities[id]
	var dmg: int = ability.getAttackDamage(self._player.characterStats, self._player.getEquippedItems())

	if ability.cooldown:
		self._cooldowns[id] = currRound + ability.cooldown

	return dmg
