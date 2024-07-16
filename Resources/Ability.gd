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
@export_range(1, 5, 1) var numberOfHits: int = 1
## Base damage of the ability.
@export var damage_base: int
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

	"""
	# @todo: weapDmg is included in the physical/magic power calculation.
	# Re-using the damage here only inflates the overall damage.
	if equipment.has("mainHand") && equipment.mainHand:
		# @todo: Support off-hand weapon?
		var weapDmg: int = equipment.mainHand.item.physicalDamage if self.damage_type == DamageType.PHYSICAL else equipment.mainHand.item.magicalDamage
		weapMod = ((self.damage_weap_modifier / 100) * weapDmg)
	else:
		# @todo: Support "Unarmed"
		weapMod = ((self.damage_weap_modifier / 100) * 2.5)
	"""

	return roundi(base + statMod + weapMod)
