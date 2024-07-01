extends Control

signal ability_selected(id: int)

# @todo: Convert this to accept a typed Resource
var abilities:
	get:
		return abilities
	set(val):
		abilities = val
		self._addButtons(val)


func _ready() -> void:
	self.abilities = Ability.abilities

func _addButtons(abils) -> void:
	for a in abils:
		var btn: Button = Button.new()
		btn.text = a.name
		btn.set_meta("ability_id", a.id)
		btn.connect("pressed", func(): self._handle_button_click(a.id))
		%GridContainer.add_child(btn)

func _handle_button_click(abilityId: int) -> void:
	ability_selected.emit(abilityId)

