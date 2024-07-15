extends Control

signal ability_selected(id: String)

@onready var gridContainer = $Outer/GridContainer

# @todo: Convert this to accept a typed Resource
var abilities: Array[Ability]:
	get:
		return abilities
	set(val):
		abilities = val
		self._addButtons(val)

func _ready() -> void:
	self.abilities = []

func setAbilities(abils: Array[Ability]) -> void:
	self.abilities = abils

func updateCooldowns(onCooldown: Array[int]) -> void:
	for btn in self.gridContainer.get_children():
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
		btn.set_meta("ability_id", a.name)
		btn.connect("pressed", func(): self._handle_button_click(a.name))
		self.gridContainer.add_child(btn)

func _handle_button_click(abilityId: String) -> void:
	ability_selected.emit(abilityId)
