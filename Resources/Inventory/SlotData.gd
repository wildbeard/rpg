extends Resource
class_name SlotData

@export var item: Item
@export var quantity: int = 1:
	set(value):
		if item && !item.isStackable && value > 1:
			quantity = 1
			push_error("%s is not stackable" % item.name)
		else:
			quantity = value
