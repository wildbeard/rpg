extends Resource
class_name Ability

enum DamageType {
	PHYSICAL,
	MAGIC,
}

enum AbilityType {
	ACTIVE,
	PASSIVE,
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

@export_category("Damage Variance")
## Damage variance allows the ability to hit between a certain value based on its
## primary damage stat (strength or intelligence).
## A range of 1-120 will give up to 120% extra damage based on the weapon's damage
## and the character's stat associated with this ability.
@export_range(1, 50, 1) var variance_low: float = 1
@export_range(1, 120, 1) var variance_high: float = 10

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

func getAttackDamage(stats: CharacterStats, equipment: Dictionary) -> int:
	var base: int = self.damage_base
	var statMod: float = 0
	var weapMod: float = 0
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

	if equipment.has("mainHand") && equipment.mainHand:
		# @todo: Support off-hand weapon?
		var weapDmg: int = equipment.mainHand.item.physicalDamage if self.damage_type == DamageType.PHYSICAL else equipment.mainHand.item.magicalDamage
		var weapStat: String = "strength" if self.damage_type == DamageType.PHYSICAL else "intelligence"
		var stat: int = stats.getAdjustedStat(weapStat)

		weapMod = ((self.damage_weap_modifier / 100) * weapDmg)
		# @todo: Not sure how much I like this. This adds anywhere between 1-120% damage
		# based off your primary stat for this attack + weapon damage modifier.
		weapMod += (randf_range(self.variance_low, self.variance_high) * stats.getAdjustedStat(weapStat))/100
	else:
		# @todo: Support "Unarmed"
		weapMod = ((self.damage_weap_modifier / 100) * 1.5)

	return roundi(base + statMod + weapMod)
