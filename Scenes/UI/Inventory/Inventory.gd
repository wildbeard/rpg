extends PanelContainer

const SlotScene: PackedScene = preload("res://Scenes/UI/Inventory/InventorySlot.tscn")

@onready var inventoryGrid = $MarginContainer/InventoryGrid

func _ready() -> void:
	for i in 16:
		self.inventoryGrid.add_child(SlotScene.instantiate())

	var item: Item = Item.new()
	item.texture = load("res://icon.svg")
	item.isStackable = false

	var ess = preload("res://Resources/Items/PureEssence.tres")
	var sword = preload("res://Resources/Items/Sword.tres")
	var hat = preload("res://Resources/Items/MagicHat.tres")

	self.inventoryGrid.get_children()[0].setItem(item)
	self.inventoryGrid.get_children()[2].setItem(ess)
	self.inventoryGrid.get_children()[3].setItem(ess)
	self.inventoryGrid.get_children()[5].setItem(sword)
	self.inventoryGrid.get_children()[8].setItem(hat)
