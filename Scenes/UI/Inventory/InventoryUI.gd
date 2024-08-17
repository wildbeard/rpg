extends Control
class_name PlayerInventory

@onready var inventory: PanelContainer = $Inventory
@onready var grabbedSlot: Slot = $GrabbedSlot
@onready var equpmentInventory: Control = $PlayerEquipment

var grabbedSlotData: SlotData = null
var prevGrabbedSlot: Slot
var prevGrabbedSlotIdx: int

func _physics_process(_delta: float) -> void:
	if self.grabbedSlot.visible:
		self.grabbedSlot.global_position = get_global_mouse_position() + Vector2(1.5, 1.5)

func setPlayerInventory(data: InventoryData) -> void:
	data.inventory_interact.connect(onInventoryInteract)
	self.inventory.setInventoryData(data)
	self.equpmentInventory.setInventoryData(data)

func onInventoryInteract(data: InventoryData, index: int, button: int, slot: Slot) -> void:
	match [self.grabbedSlotData, button]:
		[null, MOUSE_BUTTON_LEFT]:
			self.grabbedSlotData = data.getSlotData(index)
			self.prevGrabbedSlot = slot
			self.prevGrabbedSlotIdx = index
		[_, MOUSE_BUTTON_LEFT]:
			if data.canDropData(self.grabbedSlotData, slot):
				slot.setItem(self.grabbedSlotData)
				self.grabbedSlotData = data.dropSlotData(self.grabbedSlotData, index)
				self._clearPrevious()
			else:
				if self.prevGrabbedSlot \
					&& is_instance_valid(self.prevGrabbedSlot) \
					&& self.prevGrabbedSlotIdx >= 0:
						self.prevGrabbedSlot.setItem(self.grabbedSlotData)
						data.dropSlotData(self.grabbedSlotData, self.prevGrabbedSlotIdx)
						self.grabbedSlotData = null
						self._clearPrevious()
						self._updateGrabbedSlot()

			if self.prevGrabbedSlot \
				&& is_instance_valid(self.prevGrabbedSlot) \
				&& self.prevGrabbedSlot != slot:
				self.prevGrabbedSlot.setDataEmpty()

	self._updateGrabbedSlot()

func _updateGrabbedSlot() -> void:
	if self.grabbedSlotData:
		self.grabbedSlot.setItem(self.grabbedSlotData)
		self.grabbedSlot.self_modulate = Color(0, 0, 0, 0)
		self.grabbedSlot.visible = true
	else:
		self.grabbedSlot.visible = false

func _clearPrevious() -> void:
	self.prevGrabbedSlot = null
	self.prevGrabbedSlotIdx = -1
