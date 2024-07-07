extends PanelContainer
class_name Slot

@export var slotType: InventoryTypes.SlotType = InventoryTypes.SlotType.REGULAR

var slotItem: Item

func _get_drag_data(_at_position: Vector2) -> Slot:
	if !self.slotItem:
		return

	var previewControl: Control = Control.new()
	var previewTexture: TextureRect = TextureRect.new()

	previewTexture.texture = %ItemIcon.texture
	previewTexture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	previewTexture.size = Vector2(16, 16)
	#
	previewControl.add_child(previewTexture)

	self.set_drag_preview(previewControl)
	return self

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	# Only allow this item here if it matches its type or this slot's type is regular
	return data.slotItem is Item && (data.slotItem.itemType == self.slotType || self.slotType == InventoryTypes.SlotType.REGULAR)

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if !self.slotItem:
		self.setItem(data.slotItem)
		data.setDataEmpty()
	else:
		var tmp: Item = self.slotItem
		self.setItem(data)
		data.setItem(tmp)

func setItem(item: Item) -> void:
	self.slotItem = item
	%ItemIcon.texture = item.texture

	if item.isStackable:
		%ItemQty.visible = true
		%ItemQty.text = str(item.quantity)
	else:
		%ItemQty.visible = false
		%ItemQty.text = ""

func setDataEmpty() -> void:
	self.slotItem = null
	%ItemIcon.texture = null
	%ItemQty.text = ""
