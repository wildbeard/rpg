extends Node2D
class_name Attack

enum AttackType {
	MELEE,
	RANGE,
	MAGIC,
}

"""
I think ideally this serves as an object we can construct
and pass from the attacker to the target _after_ attacker
checks if it can land against target. Attacker will also
determine min/max hit.
Also: We might want to make MeleeAttack, RangeAttack, and
MagicAttack with specific properties/funcs to help deliver
info like DoT, lingering effects, etc.
"""
var attack_type: AttackType = AttackType.MELEE
var attack_min_damage: int = 1
var attack_max_damage: int = 3
var attack_damage: int = 1
