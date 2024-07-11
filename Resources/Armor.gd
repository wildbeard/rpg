extends Equipment
class_name Armor

enum ArmorType {
	LIGHT,
	MEDIUM,
	HEAVY
}

@export_enum("Light", "Medium", "Heavy") var armorType: int
@export var armorValue: int = 10
