extends Control
class_name InventoryUI

@onready var grabbedSlot: Slot = $CanvasLayer/GrabbedSlot
@onready var playerInventory: Inventory = $CanvasLayer/HBoxContainer/PlayerInventory
@onready var externalInventory: Inventory = $CanvasLayer/HBoxContainer/ExternalInventory
@onready var playerEquipment: Control = $CanvasLayer/HBoxContainer/PlayerEquipment

var _grabbedSlotData: SlotData
var _externalInventoryOwner: InventoryContainer

func _ready() -> void:
	self.grabbedSlot.self_modulate = Color(0, 0, 0, 0)

func _physics_process(delta: float) -> void:
	if self._grabbedSlotData:
		self.grabbedSlot.global_position = get_global_mouse_position() + Vector2(1.5, 1.5)

func setPlayerInventory(data: InventoryData) -> void:
	self.playerInventory.setInventoryData(data)
	self.playerEquipment.setInventoryData(data)

	if !data.inventory_interact.is_connected(_on_inventory_interact):
		data.inventory_interact.connect(self._on_inventory_interact)

func setExternalInventory(data: InventoryData) -> void:
	self.externalInventory.setInventoryData(data)

	if !data.inventory_interact.is_connected(_on_inventory_interact):
		data.inventory_interact.connect(self._on_inventory_interact)

func clearExternalInventory(invContainer: InventoryContainer) -> void:
	externalInventory.inventory_data.inventory_interact.disconnect(_on_inventory_interact)

func toggleInventory() -> void:
	playerInventory.visible = !playerInventory.visible

func toggleEquipment() -> void:
	playerEquipment.visible = !playerEquipment.visible

func toggleExternal() -> void:
	externalInventory.visible = !externalInventory.visible

func _on_inventory_interact(data: InventoryData, index: int, button: int, slot: Slot) -> void:
	match [_grabbedSlotData, button]:
		[null, MOUSE_BUTTON_LEFT]:
			# I can do slot.slotData OR data.grabSlotData(index)
			self._grabbedSlotData = data.getSlotData(index)
		[null, MOUSE_BUTTON_RIGHT]:
			var slotData: SlotData = data.getSlotData(index)

			if slotData.item.isStackable:
				var newData: SlotData = slotData.duplicate()
				# Half _should_ always be the lesser amount
				var half: int = floori(slotData.quantity / 2)
				newData.quantity = half
				slotData.quantity = slotData.quantity - half
				data.dropSlotData(slotData, index)
				_grabbedSlotData = newData
			else:
				_grabbedSlotData = slotData
		[_, MOUSE_BUTTON_LEFT]:
			if data.canDropData(self._grabbedSlotData, slot):
				self._grabbedSlotData = data.dropSlotData(self._grabbedSlotData, index)
		[_, MOUSE_BUTTON_RIGHT]:
			if _grabbedSlotData && data.canDropData(_grabbedSlotData, slot):
				var slotData: SlotData = _grabbedSlotData.duplicate()
				slotData.quantity = 1
				_grabbedSlotData.quantity -= 1
				data.dropSlotData(slotData, index)

	self._updateGrabbedSlotUI()

func _updateGrabbedSlotUI() -> void:
	if self._grabbedSlotData:
		self.grabbedSlot.setSlotData(self._grabbedSlotData)
		self.grabbedSlot.visible = true
	else:
		self.grabbedSlot.visible = false
		self.grabbedSlot.setDataEmpty()
