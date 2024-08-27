extends Resource
class_name InventoryData

signal inventory_updated(data: InventoryData)
signal inventory_interact(data: InventoryData, index: int, button: int, slot: Slot)

@export var data: Array[SlotData]:
	set(d):
		data = d
		inventory_updated.emit(self)

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
@export var is_external: bool = false

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

func on_slot_clicked(index: int, button: int, slot: Slot) -> void:
	inventory_interact.emit(self, index, button, slot)

func getData(index: int) -> SlotData:
	var slotData: SlotData

	if index < 0:
		slotData = _getEquipmentData(index)
	else:
		slotData = data[index]

	return slotData

func getSlotData(index: int) -> SlotData:
	var slotData: SlotData = getData(index)

	if slotData:
		_setData(index, null)
		return slotData
	else:
		return null

func hasSlotData(index: int) -> bool:
	return !!data[index]

func dropSlotData(slotData: SlotData, index: int) -> SlotData:
	var existing: SlotData = getData(index)

	if existing && _canFullyStack(existing, slotData):
		existing.quantity += slotData.quantity
		_setData(index, existing)
		existing = null
	elif existing && _canStack(existing, slotData):
		var remaining: int = (existing.quantity + slotData.quantity) - existing.item.maxStack
		existing.quantity = existing.item.maxStack
		slotData.quantity = remaining
		existing = slotData
	else:
		_setData(index, slotData)

	return existing

func emptySlot(idx: int) -> void:
	print('attempting to empty %d' % idx)
	if hasSlotData(idx):
		print('has data in %d' % idx)
		_setData(idx, null)

func canDropData(slotData: SlotData, slot: Slot) -> bool:
	return slotData.item.itemType == slot.slotType || slot.slotType == InventoryTypes.SlotType.REGULAR

func grabSlotData(index: int) -> SlotData:
	return data[index]

func _canStack(a: SlotData, b: SlotData) -> bool:
	return (a.item == b.item && a.item.isStackable)

func _canFullyStack(a: SlotData, b: SlotData) -> bool:
	return (_canStack(a, b) && a.quantity + b.quantity <= a.item.maxStack)

func _getEquipmentData(index: int) -> SlotData:
	return equipment[equipmentMap[index]]

func _setData(index: int, sd: SlotData = null) -> void:
	var curr: Array[SlotData] = data

	if index < 0:
		equipment[equipmentMap[index]] = sd
	else:
		curr[index] = sd

	data = curr
