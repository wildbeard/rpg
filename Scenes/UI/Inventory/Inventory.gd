extends PanelContainer
class_name Iventory

const SlotScene: PackedScene = preload("res://Scenes/UI/Inventory/InventorySlot.tscn")

@onready var inventoryGrid = $MarginContainer/InventoryGrid

func setInventoryData(data: InventoryData) -> void:
	data.inventory_updated.connect(populateInventory)
	self.populateInventory(data)

func populateInventory(data: InventoryData) -> void:
	if !self.inventoryGrid.get_children().size():
		for sd in data.data:
			var slot: Slot = SlotScene.instantiate()
			slot.slot_clicked.connect(data.onSlotClicked)

			if sd:
				slot.setItem(sd)

			self.inventoryGrid.add_child(slot)
	else:
		for idx in data.data.size():
			var sd: SlotData = data.data[idx]
			
			if sd:
				self.inventoryGrid.get_children()[idx].setItem(sd)
