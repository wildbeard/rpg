extends Control

@export var ability: Ability

@onready var ability_icon = $AbilityIcon
@onready var ability_name = $AbilityName
@onready var ability_description = $AbilityDescription
@onready var ability_element = $AbilityElement
@onready var cooldown = $Cooldown

func _ready() -> void:
	self.ability_name.text = ability.name
	self.ability_icon.texture = self.ability.icon
	# Ugh, globals
	self.ability_description.text = self.ability.getDescription(PlayerManager.player)
	self.ability_element.text = "Element: %s" % self.ability.getElementType()
	self.cooldown.text = "CD: %d" % self.ability.cooldown
