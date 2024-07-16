extends Resource
class_name Item

enum ItemRarity {
	Common,
	Rare,
	Epic,
	Legendary,
}

@export var texture: Texture
@export var itemType: InventoryTypes.SlotType = InventoryTypes.SlotType.REGULAR

@export_category("Basics")
@export var name: String
@export_multiline var description: String
@export var price: int = 10
@export var rarity: ItemRarity

@export_category("Stacking")
@export var maxStack: int = 99
@export var isStackable: bool = false
