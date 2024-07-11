extends Resource
class_name InventoryData

signal inventory_updated(data: InventoryData)
signal inventory_interact(data: InventoryData, index: int, button: int)

@export var data: Array[SlotData]

func onSlotClicked(index: int, button: int) -> void:
	inventory_interact.emit(self, index, button)

func getSlotData(index: int) -> SlotData:
	var slotData: SlotData = self.data[index]

	if slotData:
		self.data[index] = null
		inventory_updated.emit(self)
		return slotData
	else:
		return

func dropSlotData(slotData: SlotData, index: int) -> SlotData:
	var existing: SlotData = self.data[index]

	if existing && self._canFullyStack(existing, slotData):
			existing.quantity += slotData.quantity
			self.data[index] = existing
			existing = null
	elif existing && self._canStack(existing, slotData):
		var remaining: int = (existing.quantity + slotData.quantity) - existing.item.maxStack
		existing.quantity = existing.item.maxStack
		slotData.quantity = remaining
		existing = slotData
	else:
		self.data[index] = slotData

	inventory_updated.emit(self)

	return existing

func _canStack(a: SlotData, b: SlotData) -> bool:
	return (a.item == b.item && a.item.isStackable)

func _canFullyStack(a: SlotData, b: SlotData) -> bool:
	return (self._canStack(a, b) && a.quantity + b.quantity <= a.item.maxStack)
