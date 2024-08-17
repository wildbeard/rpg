extends Control

@onready var head: Slot = $Head # 0
@onready var chest: Slot = $Chest
@onready var neck: Slot = $Neck
@onready var offHand: Slot = $OffHand
@onready var mainHand: Slot = $MainHand
@onready var leg: Slot = $Legs
@onready var hand: Slot = $Hands
@onready var boot: Slot = $Boots # 7

var invSlots: Array[String] = [
	"head",
	"chest",
	"neck",
	"mainHand",
	"offHand",
	"leg",
	"boot",
	"hand",
]

var equipmentMap: Dictionary = {
	-1: "head",
	-2: "neck",
	-3: "chest",
	-4: "mainHand",
	-5: "offHand",
	-6: "leg",
	-7: "boot",
	-8: "hand",
}

func setInventoryData(data: InventoryData) -> void:
	data.inventory_updated.connect(populateInventory)
	self.populateInventory(data)

func populateInventory(data: InventoryData) -> void:
	for key in self.equipmentMap:
		var slot: Slot = self._getSlot(key)
		var sd: SlotData = data.getData(key)

		if !slot.is_connected("slot_clicked", data.onSlotClicked):
			slot.slot_clicked.connect(data.onSlotClicked)

		if sd:
			slot.setItem(sd)

func _getSlot(key: int) -> Slot:
	return self[self.equipmentMap[key]]
