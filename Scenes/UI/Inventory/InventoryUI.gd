extends Control

@onready var inventory: PanelContainer = $Inventory
@onready var grabbedSlot: Slot = $GrabbedSlot

var grabbedSlotData: SlotData = null

func _physics_process(_delta: float) -> void:
	if self.grabbedSlot.visible:
		self.grabbedSlot.global_position = get_global_mouse_position() + Vector2(10, 10)

func setPlayerInventory(data: InventoryData) -> void:
	data.inventory_interact.connect(onInventoryInteract)
	self.inventory.setInventoryData(data)

func onInventoryInteract(data: InventoryData, index: int, button: int) -> void:
	match [self.grabbedSlotData, button]:
		[null, MOUSE_BUTTON_LEFT]:
			self.grabbedSlotData = data.getSlotData(index)
		[_, MOUSE_BUTTON_LEFT]:
			self.grabbedSlotData = data.dropSlotData(self.grabbedSlotData, index)

	self.updateGrabbedSlot()

func updateGrabbedSlot() -> void:
	if self.grabbedSlotData:
		self.grabbedSlot.setItem(self.grabbedSlotData)
		self.grabbedSlot.visible = true
	else:
		self.grabbedSlot.visible = false
