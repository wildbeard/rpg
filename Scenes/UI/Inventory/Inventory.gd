extends Control
class_name Inventory

const SLOT = preload("res://Scenes/UI/Inventory/InventorySlot.tscn")

@export var inventory_data: InventoryData

@onready var inventoryGrid: GridContainer = $MarginContainer/InventoryGrid

func setInventoryData(data: InventoryData) -> void:
	self.inventory_data = data
	self._populateInventory(self.inventory_data)

	if !inventory_data.inventory_updated.is_connected(_populateInventory):
		self.inventory_data.inventory_updated.connect(self._populateInventory)

func _populateInventory(data: InventoryData) -> void:
	self.inventory_data = data

	if !self.inventoryGrid.get_children().size():
		for sd in self.inventory_data.data:
			var slot: Slot = self.SLOT.instantiate()
			slot.slot_clicked.connect(self.inventory_data.on_slot_clicked)

			if sd:
				slot.setSlotData(sd)

			self.inventoryGrid.add_child(slot)
	else:
		for idx in self.inventory_data.data.size():
			var sd: SlotData = self.inventory_data.data[idx]
			
			if sd:
				self.inventoryGrid.get_children()[idx].setSlotData(sd)
			else:
				self.inventoryGrid.get_children()[idx].setDataEmpty()
