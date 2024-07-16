extends Node

var inventory: Array = []
var equipment: Dictionary = {
	head = null,
	neck = null,
	body = null,
	hand = null,
	leg = null,
	feet = null,
	main_hand = null,
	off_hand = null,
}

func _ready() -> void:
	pass

func equip(item: Equipment) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		self.visible = !self.visible
