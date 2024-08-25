extends Control

@export var inventory_data: InventoryData

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
	inventory_data = data
	_populateInventory(data)

	if !inventory_data.inventory_updated.is_connected(_populateInventory):
		inventory_data.inventory_updated.connect(_populateInventory)

func equipItem(slotData: SlotData) -> SlotData:
	var currentlyEquipped: SlotData
	var slot: Slot

	print(slotData.item.name)
	# @TODO: Fix this dumb shit
	match [slotData.item.itemType]:
		[InventoryTypes.SlotType.HEAD]:
			slot = head
		[InventoryTypes.SlotType.NECK]:
			slot = neck
		[InventoryTypes.SlotType.BODY]:
			slot = chest
		[InventoryTypes.SlotType.HAND]:
			slot = hand
		[InventoryTypes.SlotType.MAIN_HAND]:
			slot = mainHand
		[InventoryTypes.SlotType.OFF_HAND]:
			slot = offHand
		[InventoryTypes.SlotType.LEG]:
			slot = leg
		[InventoryTypes.SlotType.FEET]:
			slot = boot

	if slot && slot.slotData:
		currentlyEquipped = slot.slotData
	elif slot:
		slot.slotData = slotData

	return currentlyEquipped

func _populateInventory(data: InventoryData) -> void:
	inventory_data = data

	for key in equipmentMap:
		var slot: Slot = _getSlot(key)
		var sd: SlotData = data.getData(key)

		if !slot.is_connected("slot_clicked", inventory_data.on_slot_clicked):
			slot.slot_clicked.connect(inventory_data.on_slot_clicked)

		if sd:
			slot.setSlotData(sd)
		else:
			slot.setDataEmpty()

func _getSlot(key: int) -> Slot:
	return self[equipmentMap[key]]
