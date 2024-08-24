extends Control
class_name Inventory

const SLOT = preload("res://Scenes/UI/Inventory/InventorySlot.tscn")

@export var inventory_data: InventoryData

@onready var inventoryGrid: GridContainer = $MarginContainer/InventoryGrid

func setInventoryData(data: InventoryData) -> void:
	inventory_data = data
	_populateInventory(inventory_data)

	if !inventory_data.inventory_updated.is_connected(_populateInventory):
		inventory_data.inventory_updated.connect(_populateInventory)

func _populateInventory(data: InventoryData) -> void:
	inventory_data = data

	if !inventoryGrid.get_children().size():
		for sd in inventory_data.data:
			var slot: Slot = SLOT.instantiate()
			slot.slot_clicked.connect(inventory_data.on_slot_clicked)

			if sd:
				slot.setSlotData(sd)

			inventoryGrid.add_child(slot)
	else:
		for idx in inventory_data.data.size():
			var sd: SlotData = inventory_data.data[idx]
			
			if sd:
				inventoryGrid.get_children()[idx].setSlotData(sd)
			else:
				inventoryGrid.get_children()[idx].setDataEmpty()
