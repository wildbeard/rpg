extends Control
class_name InventoryUI

@onready var grabbedSlot: Slot = $CanvasLayer/GrabbedSlot
@onready var playerInventory: Inventory = $CanvasLayer/HBoxContainer/PlayerInventory
@onready var externalInventory: Inventory = $CanvasLayer/HBoxContainer/ExternalInventory
@onready var playerEquipment: Control = $CanvasLayer/HBoxContainer/PlayerEquipment
@onready var equipmentStats: Control = $CanvasLayer/HBoxContainer/EquipmentStats
@onready var colorRect: ColorRect = $CanvasLayer/ColorRect
@onready var hBoxContainer: HBoxContainer = $CanvasLayer/HBoxContainer

var _grabbedSlotData: SlotData
var _externalInventoryOwner: InventoryContainer

func _ready() -> void:
	grabbedSlot.self_modulate = Color(0, 0, 0, 0)

func _physics_process(delta: float) -> void:
	if _grabbedSlotData:
		grabbedSlot.global_position = get_global_mouse_position() + Vector2(1, 1)

func setPlayerInventory(data: InventoryData) -> void:
	playerInventory.setInventoryData(data)
	playerEquipment.setInventoryData(data)

	if !data.inventory_interact.is_connected(_on_inventory_interact):
		data.inventory_interact.connect(_on_inventory_interact)

func setExternalInventory(data: InventoryData) -> void:
	data.is_external = true
	externalInventory.setInventoryData(data)

	if !data.inventory_interact.is_connected(_on_inventory_interact):
		data.inventory_interact.connect(_on_inventory_interact)

func clearExternalInventory(invContainer: InventoryContainer) -> void:
	externalInventory.inventory_data.inventory_interact.disconnect(_on_inventory_interact)

func toggleInventory() -> void:
	playerInventory.visible = !playerInventory.visible
	colorRect.visible = playerInventory.visible

func toggleEquipment() -> void:
	playerEquipment.visible = !playerEquipment.visible
	equipmentStats.visible = !equipmentStats.visible

func toggleExternal() -> void:
	if playerInventory.visible:
		playerInventory.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hBoxContainer.add_theme_constant_override("separation", 6)
	else:
		playerInventory.size_flags_horizontal = Control.SIZE_EXPAND + Control.SIZE_SHRINK_CENTER
		hBoxContainer.add_theme_constant_override("separation", 32)

	toggleInventory()
	externalInventory.visible = !externalInventory.visible

func _on_inventory_interact(data: InventoryData, index: int, button: int, slot: Slot) -> void:
	match [_grabbedSlotData, button]:
		[null, MOUSE_BUTTON_LEFT]:
			# I can do slot.slotData OR data.grabSlotData(index)
			_grabbedSlotData = data.getSlotData(index)
		[null, MOUSE_BUTTON_RIGHT]:
			var slotData: SlotData = data.getSlotData(index)

			if data.is_external:
				var intendedIdx: int

				"""
					This will attempt to quickly move an item to the player's inventory.
					If the item is stackable, look for a slot of the same item where it can stack.
					If one exists, merge the two. If it can't, drop it in the first available slot.
					@TODO: Fill a slot to maxStacks + drop in an empty slot
				"""
				if slotData.item.isStackable:
					var opts: Array[SlotData] = playerInventory.inventory_data.data\
						.filter(func(sd: SlotData): return sd && (sd.quantity + slotData.quantity < slotData.item.maxStack))
					
					if opts.size():
						intendedIdx = playerInventory.inventory_data.data.find(opts[0])
					else:
						intendedIdx = playerInventory.inventory_data.data.find(null)
				else:
					intendedIdx = playerInventory.inventory_data.data.find(null)

				if intendedIdx >= 0:
					playerInventory.inventory_data.dropSlotData(slotData, intendedIdx)
				else:
					_grabbedSlotData = slotData
			else:
				# @TODO: Doesn't work frome external inventory
				if slotData && slotData.item is Equipment:
					var d: Dictionary = playerEquipment.equipItem(slotData)

					if d.slot_idx != 0:
						data.dropSlotData(slotData, d.slot_idx)

						if d.currently_equipped:
							data.dropSlotData(d.currently_equipped, index)
					else:
						_grabbedSlotData = slotData
				elif slotData && slotData.item.isStackable:
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
			if data.canDropData(_grabbedSlotData, slot):
				_grabbedSlotData = data.dropSlotData(_grabbedSlotData, index)
		[_, MOUSE_BUTTON_RIGHT]:
			if _grabbedSlotData && data.canDropData(_grabbedSlotData, slot):
				var slotData: SlotData = _grabbedSlotData.duplicate()
				slotData.quantity = 1
				_grabbedSlotData.quantity -= 1
				data.dropSlotData(slotData, index)

	_updateGrabbedSlotUI()

func _updateGrabbedSlotUI() -> void:
	if _grabbedSlotData:
		grabbedSlot.setSlotData(_grabbedSlotData)
		grabbedSlot.visible = true
	else:
		grabbedSlot.visible = false
		grabbedSlot.setDataEmpty()
