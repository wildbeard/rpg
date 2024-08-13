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
	self.ability_name.text = ability.name
	self.ability_icon.texture = self.ability.icon
	# Ugh, globals
	self.ability_description.text = self.ability.getDescription(PlayerManager.player)
	self.ability_element.text = "Element: %s" % self.ability.getElementType()
	self.cooldown.text = "CD: %d" % self.ability.cooldown

	self.connect("mouse_entered", func(): self._mouseEvent(true))
	self.connect("mouse_exited", func(): self._mouseEvent(false))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
		&& self._hovered \
		&& event.button_index == MOUSE_BUTTON_LEFT:
			self.handleFocus()

func _mouseEvent(isHovered: bool) -> void:
	self._hovered = isHovered

func handleFocus() -> void:
	var t: Tween = create_tween()
	t.tween_property(self, "scale", Vector2(1.025, 1.025), 0.25)
	self.select.emit(self.ability)
	self._selected = true

func handleExit(emitEvent: bool = true) -> void:
	var t: Tween = create_tween()
	t.tween_property(self, "scale", Vector2(1, 1), 0.25)

	if emitEvent:
		self.deselect.emit()
