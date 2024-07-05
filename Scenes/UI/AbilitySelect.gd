extends Control

signal ability_selected(id: int)

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

func _addButtons(abils: Array[Ability]) -> void:
	# @todo: This needs to be better?
	for a in abils.filter(func(a): return !has_node("Outer/GridContainer/ability_%d" % a.id)):
		var btn: Button = Button.new()
		btn.name = "ability_%d" % a.id
		btn.text = a.name
		btn.connect("pressed", func(): self._handle_button_click(a.id))
		%GridContainer.add_child(btn)

func _handle_button_click(abilityId: int) -> void:
	ability_selected.emit(abilityId)

