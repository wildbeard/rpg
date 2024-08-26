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

func equipItem(slotData: SlotData) -> Dictionary:
	var currentlyEquipped: SlotData
	var slotIdx: int = 0

	# @TODO: Fix this dumb shit
	match [slotData.item.itemType]:
		[InventoryTypes.SlotType.HEAD]:
			currentlyEquipped = head.slotData
			slotIdx = -1
		[InventoryTypes.SlotType.NECK]:
			currentlyEquipped = neck.slotData
			slotIdx = -2
		[InventoryTypes.SlotType.BODY]:
			currentlyEquipped = chest.slotData
			slotIdx = -3
		[InventoryTypes.SlotType.HAND]:
			currentlyEquipped = hand.slotData
			slotIdx = -8
		[InventoryTypes.SlotType.MAIN_HAND]:
			currentlyEquipped = mainHand.slotData
			slotIdx = -4
		[InventoryTypes.SlotType.OFF_HAND]:
			currentlyEquipped = offHand.slotData
			slotIdx = -5
		[InventoryTypes.SlotType.LEG]:
			currentlyEquipped = leg.slotData
			slotIdx = -6
		[InventoryTypes.SlotType.FEET]:
			currentlyEquipped = boot.slotData
			slotIdx = -7

	return { 'slot_idx': slotIdx, 'currently_equipped': currentlyEquipped }

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
