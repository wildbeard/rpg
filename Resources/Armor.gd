extends Equipment
class_name Armor

enum ArmorType {
	LIGHT,
	MEDIUM,
	HEAVY
}

@export_enum("Light", "Medium", "Heavy") var armorType: int
@export var physicalDefense: int = 1
@export var magicalDefense: int = 1

var _defenseWeight: Dictionary = {
	ArmorType.LIGHT: 175.0,
	ArmorType.MEDIUM: 165.0,
	ArmorType.HEAVY: 145.0,
}

func _getItemDefenseWeight() -> float:
	return _defenseWeight[armorType]

func getDamageReduction(physical: bool = true) -> float:
	var armorVal: float = float(physicalDefense if physical else magicalDefense)
	var weight: float = _getItemDefenseWeight()

	return (armorVal / (armorVal + _getItemDefenseWeight()))
