extends Resource
class_name Item

@export var texture: Texture
@export var itemType: InventoryTypes.SlotType = InventoryTypes.SlotType.REGULAR
@export var quantity: int = 0
@export var isStackable: bool = false
