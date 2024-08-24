extends Control
class_name AbilityCard

signal select(ability: Ability)
signal deselect()

@export var ability: Ability

@onready var ability_icon = $AbilityIcon
@onready var ability_name = $AbilityName
@onready var ability_description = $AbilityDescription
@onready var ability_element = $AbilityElement
@onready var cooldown = $Cooldown

var _hovered: bool = false
var _selected: bool = false

func _ready() -> void:
	ability_name.text = ability.name
	ability_icon.texture = ability.icon
	# Ugh, globals
	ability_description.text = ability.getDescription(PlayerManager.player)

	var elType: String = ability.getElementType()

	if elType == 'N/A':
		ability_element.text = 'Neutral'
	else:
		ability_element.text = "%s" % ability.getElementType()

	cooldown.text = str(ability.cooldown)

	connect("mouse_entered", func(): _mouseEvent(true))
	connect("mouse_exited", func(): _mouseEvent(false))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
		&& _hovered \
		&& event.button_index == MOUSE_BUTTON_LEFT:
			handleFocus()

func _mouseEvent(isHovered: bool) -> void:
	_hovered = isHovered

func handleFocus() -> void:
	var t: Tween = create_tween()
	t.tween_property(self, "scale", Vector2(1.025, 1.025), 0.25)
	select.emit(ability)
	_selected = true

func handleExit(emitEvent: bool = true) -> void:
	var t: Tween = create_tween()
	t.tween_property(self, "scale", Vector2(1, 1), 0.25)

	if emitEvent:
		deselect.emit()
