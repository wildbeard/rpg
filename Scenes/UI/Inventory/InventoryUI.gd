extends Control

@onready var inventory: PanelContainer = $Inventory
@onready var equpmentInventory = $EqupmentInventory
@onready var grabbedSlot: Slot = $GrabbedSlot

var grabbedSlotData: SlotData = null
var prevGrabbedSlot: Slot

func _physics_process(_delta: float) -> void:
	if self.grabbedSlot.visible:
		self.grabbedSlot.global_position = get_global_mouse_position() + Vector2(10, 10)

func setPlayerInventory(data: InventoryData) -> void:
	data.inventory_interact.connect(onInventoryInteract)
	self.inventory.setInventoryData(data)
	self.equpmentInventory.setInventoryData(data)

func onInventoryInteract(data: InventoryData, index: int, button: int, slot: Slot) -> void:
	match [self.grabbedSlotData, button]:
		[null, MOUSE_BUTTON_LEFT]:
			self.grabbedSlotData = data.getSlotData(index)
			self.prevGrabbedSlot = slot
		[_, MOUSE_BUTTON_LEFT]:
			if data.canDropData(self.grabbedSlotData, slot):
				slot.setItem(self.grabbedSlotData)
				self.grabbedSlotData = data.dropSlotData(self.grabbedSlotData, index)

			if self.prevGrabbedSlot \
				&& is_instance_valid(self.prevGrabbedSlot) \
				&& self.prevGrabbedSlot != slot:
				self.prevGrabbedSlot.setDataEmpty()

	self.updateGrabbedSlot()

func updateGrabbedSlot() -> void:
	if self.grabbedSlotData:
		self.grabbedSlot.setItem(self.grabbedSlotData)
		self.grabbedSlot.visible = true
	else:
		self.grabbedSlot.visible = false
