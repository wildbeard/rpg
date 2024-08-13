extends Resource
class_name Ability

enum DamageType {
	PHYSICAL,
	MAGIC,
}

enum AbilityType {
	ACTIVE,
	PASSIVE,
	PASSIVE_DEFENSE,
}

enum TargetType {
	SINGLE,
	MULTI,
	HEAL,
	HEAL_MULTI,
	SHIELD,
}

enum DamageAttribute {
	PHYSICAL,
	MAGIC,
}

enum ElementType {
	NONE,
	FIRE,
	WATER,
	EARTH,
	AIR,
	HOLY,
	UNHOLY,
}

@export var icon: Texture
@export var name: String
@export_multiline var description: String

@export_category("Ability Target & Damage Type")
@export var ability_type: AbilityType
@export var target_type: TargetType
@export var damage_type: DamageType
@export var element_type: ElementType

@export_category("Values")
## The amount of rounds before the ability is available for use.
## A value of 0 is available the next round.
@export var cooldown: int

## The number of times this ability will hit the target.
@export_range(1, 5, 1) var number_of_hits: int = 1
## Base damage of the ability.
@export var damage_base: int

@export_category("Weapon & Stat Modifier")
## A percentage of the weapon's damage to use.
## Example: If the weapon is Magical, with 15 magic damage, and this value is 25
## then 3.75 will be added to the total damage.
@export var damage_weap_modifier: float
## Option for which type of power to scale off of.
## Multiple can be picked.
@export var damage_stat_type: Array[DamageAttribute]
## Percent values the Damage Stat Type use to scale. This *must* match, in order, 
## the Damage Stat Type.
@export var damage_stat_modifier: Array[float]

var _physicalColor: String = '#eb4034'
var _magicColor: String = '#3489eb'

func getAttackDamage(stats: CharacterStats, equipment: Dictionary) -> int:
	var base: int = self.damage_base
	var statMod: float = self.getDamageFromStats(stats)
	var weapMod: float = self.getDamageFromEquipment(equipment)

	return roundi(base + statMod + weapMod)

func getDamageFromStats(stats: CharacterStats) -> float:
	var statMod: float = 0
	var idx: int = 0

	for key in self.damage_stat_type:
		var dmgStat: String = DamageAttribute.keys()[key].to_upper()
		var baseStat: int = 0
		# @todo: Stat bonus is a part of physical/magic power
		var statBonus: int = 0
		
		if dmgStat == "PHYSICAL":
			baseStat = stats.getPhysicalPower()
		else:
			baseStat = stats.getMagicalPower()
		
		statMod += ((baseStat + statBonus) * (self.damage_stat_modifier[idx] / 100))

	return statMod

func getDamageFromEquipment(equipment: Dictionary) -> float:
	var weapMod: float = 0

	if equipment.has("mainHand") && equipment.mainHand:
		# @todo: Support off-hand weapon?
		var weapDmg: int = equipment.mainHand.item.physicalDamage if self.damage_type == DamageType.PHYSICAL else equipment.mainHand.item.magicalDamage
		var weapStat: String = "strength" if self.damage_type == DamageType.PHYSICAL else "intelligence"
		weapMod = ((self.damage_weap_modifier / 100) * weapDmg)
	else:
		# @todo: Support "Unarmed"
		weapMod = ((self.damage_weap_modifier / 100) * 1.5)

	return weapMod

func getDescription(character: Character) -> String:
	var input: String = self.description

	if !input:
		input = 'Deals %bd(+%dmgMod) %dt damage.'

	var descKeys: Dictionary = {
		'%bd': func(): return self.damage_base,
		'%dmgMod': func(): return \
			roundi(\
				self.getDamageFromStats(character.characterStats) + self.getDamageFromEquipment(character.getEquippedItems())\
			),
		'%dmgPhys': func(): return '[color=%s]%s[/color]' % [self._physicalColor, self._getPhysicalDamage(character.characterStats)],
		'%dmgMag': func(): return '[color=%s]%s[/color]' % [self._magicColor, self._getMagicDamage(character.characterStats)],
		'%dt': func(): return ('[color=%s]Physical[/color]' % self._physicalColor) \
			if Ability.DamageType.PHYSICAL == self.damage_type \
			else ('[color=%s]Magic[/color]' % self._magicColor),
		'%et': self.getElementType,
		'%h': func(): return self.number_of_hits
	}

	for key in descKeys:
		input = input.replace(key, str(descKeys[key].call()))

	return input

func getElementType() -> String:
	var elType: String = Ability.ElementType.keys()[self.element_type].capitalize()
	return elType if elType != 'None' else 'N/A'

func _getPhysicalDamage(stats: CharacterStats) -> float:
	var dmg: float = 0.0
	var keys: Array = self.DamageAttribute.keys()

	for idx in self.damage_stat_type.size():
		if keys[idx] == 'PHYSICAL':
			dmg = ((self.damage_stat_modifier[idx] / 100) * stats.getPhysicalPower())

	return dmg

func _getMagicDamage(stats: CharacterStats) -> float:
	var dmg: float = 0.0
	var keys: Array = self.DamageAttribute.keys()

	for idx in self.damage_stat_type.size():
		if keys[idx] == 'MAGIC':
			dmg = ((self.damage_stat_modifier[idx] / 100) * stats.getMagicalPower())

	return dmg
