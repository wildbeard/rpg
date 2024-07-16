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
