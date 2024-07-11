extends PanelContainer
class_name Slot

signal slot_clicked(index: int, button: int)

@export var slotType: InventoryTypes.SlotType = InventoryTypes.SlotType.REGULAR

var slotData: SlotData

func _ready() -> void:
	self.connect("gui_input", _on_gui_input)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
		&& (event.button_index == MOUSE_BUTTON_MASK_LEFT || event.button_index == MOUSE_BUTTON_RIGHT) \
		&& event.is_pressed():
			var index: int = get_index()
			if self.slotType != InventoryTypes.SlotType.REGULAR:
				if index == 0:
					index = -1
				else:
					index = index * -1 - 1
			slot_clicked.emit(index, event.button_index, self)

func setItem(data: SlotData) -> void:
	self.slotData = data
	self.tooltip_text = "%s\n%s" % [data.item.name, data.item.description]
	%ItemIcon.texture = data.item.texture

	if data.item.isStackable:
		%ItemQty.visible = true
		%ItemQty.text = str(data.quantity)
	else:
		%ItemQty.visible = false
		%ItemQty.text = ""

func setDataEmpty() -> void:
	self.slotData = null
	%ItemIcon.texture = null
	%ItemQty.text = ""
