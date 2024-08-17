extends Resource
class_name InventoryData

signal inventory_updated(data: InventoryData)
signal inventory_interact(data: InventoryData, index: int, button: int)

@export var data: Array[SlotData]
@export var equipment: Dictionary = {
	"head": null, # -1
	"neck": null,
	"chest": null,
	"mainHand": null,
	"offHand": null,
	"leg": null,
	"boot": null,
	"hand": null, # -8
}

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

func onSlotClicked(index: int, button: int, slot: Slot) -> void:
	# "Picks up" the data from the slot so it is no longer in the same spot
	if button != MOUSE_BUTTON_RIGHT:
		slot.setDataEmpty()
	inventory_interact.emit(self, index, button, slot)

func getData(index: int) -> SlotData:
	var slotData: SlotData

	if index < 0:
		slotData = self._getEquipmentData(index)
	else:
		slotData = self.data[index]

	return slotData

func getSlotData(index: int) -> SlotData:
	var slotData: SlotData = self.getData(index)

	if slotData:
		self._setData(index, null)
		# self.data[index] = null
		inventory_updated.emit(self)
		return slotData
	else:
		return

func dropSlotData(slotData: SlotData, index: int) -> SlotData:
	var existing: SlotData = self.getData(index)

	if existing && self._canFullyStack(existing, slotData):
			existing.quantity += slotData.quantity
			self._setData(index, existing)
			# self.data[index] = existing
			existing = null
	elif existing && self._canStack(existing, slotData):
		var remaining: int = (existing.quantity + slotData.quantity) - existing.item.maxStack
		existing.quantity = existing.item.maxStack
		slotData.quantity = remaining
		existing = slotData
	else:
		self._setData(index, slotData)

	inventory_updated.emit(self)

	return existing

func canDropData(slotData: SlotData, slot: Slot) -> bool:
	return slotData.item.itemType == slot.slotType || slot.slotType == InventoryTypes.SlotType.REGULAR

func _canStack(a: SlotData, b: SlotData) -> bool:
	return (a.item == b.item && a.item.isStackable)

func _canFullyStack(a: SlotData, b: SlotData) -> bool:
	return (self._canStack(a, b) && a.quantity + b.quantity <= a.item.maxStack)

func _getEquipmentData(index: int) -> SlotData:
	return self.equipment[self.equipmentMap[index]]

func _setData(index: int, sd: SlotData = null) -> void:
	if index < 0:
		self.equipment[self.equipmentMap[index]] = sd
	else:
		self.data[index] = sd
