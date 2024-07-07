extends PanelContainer

const SlotScene: PackedScene = preload("res://Scenes/UI/Inventory/InventorySlot.tscn")

@onready var inventoryGrid = $MarginContainer/InventoryGrid

func _ready() -> void:
	for i in 16:
		self.inventoryGrid.add_child(SlotScene.instantiate())

	var item: Item = Item.new()
	item.texture = load("res://icon.svg")
	item.isStackable = false

	self.inventoryGrid.get_children()[0].setItem(item)
