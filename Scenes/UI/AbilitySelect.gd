extends Control

signal ability_selected(id: String)

@onready var gridContainer = $Outer/GridContainer

# @todo: Convert this to accept a typed Resource
var abilities: Array[Ability]:
	get:
		return abilities
	set(val):
		abilities = val
		_addButtons(val)

func _ready() -> void:
	abilities = []

func setAbilities(abils: Array[Ability]) -> void:
	abilities = abils

func updateCooldowns(onCooldown: Array[String]) -> void:
	for btn in gridContainer.get_children():
		if onCooldown.find(btn.get_meta("ability_id")) > -1:
			btn.disabled = true
		else:
			btn.disabled = false

func _addButtons(abils: Array[Ability]) -> void:
	# @todo: This needs to be better?
	for a in abils.filter(func(a): return !has_node("Outer/GridContainer/ability_%s" % a.name)):
		var btn: Button = Button.new()
		btn.name = "ability_%s" % a.name
		btn.text = a.name
		btn.theme = preload("res://Themes/Base.tres")
		btn.set_meta("ability_id", a.name)
		btn.connect("pressed", func(): _handle_button_click(a.name))
		gridContainer.add_child(btn)

func _handle_button_click(abilityId: String) -> void:
	ability_selected.emit(abilityId)
