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
	return self._defenseWeight[self.armorType]

func getDamageReduction(physical: bool = true) -> float:
	var armorVal: float = float(self.physicalDefense if physical else self.magicalDefense)
	var weight: float = self._getItemDefenseWeight()
	var mit: float = armorVal / (armorVal + weight)

	return (armorVal / (armorVal + self._getItemDefenseWeight()))
