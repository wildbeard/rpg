extends Resource
class_name Item

@export var texture: Texture
@export var itemType: InventoryTypes.SlotType = InventoryTypes.SlotType.REGULAR

@export_category("Basics")
@export var name: String
@export_multiline var description: String
@export var price: int = 10

@export_category("Quantity & Stacking")
@export var quantity: int = 0:
	set(value):
		if !isStackable:
			quantity = 1
		else:
			quantity = value
@export var maxStack: int = 99
@export var isStackable: bool = false
