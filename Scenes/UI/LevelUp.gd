extends Control
class_name LevelUpScene

signal confirm_choices(updates: Dictionary)

@onready var _allAbilities = preload("res://Resources/Abilities.tres")
@onready var reroll = $CanvasLayer/ButtonHBox/RerollBtn
@onready var canvas_layer = $CanvasLayer

var stats: PlayerStats = PlayerManager.stats
var _statsLocal: Dictionary = {
	"strength": 0,
	"intelligence": 0,
	"wisdom": 0,
	"vitality": 0,
	"dexterity": 0,
	"speed": 0,
}
var _statNameStrings: Dictionary = {
	"strength": "Strength",
	"intelligence": "Intelligence",
	"wisdom": "Wisdom",
	"dexterity": "Dexterity",
	"vitality": "Vitality",
	"speed": "The Fast"
}
var _pointsAvail: int = 5
var _cards: Array[AbilityCard] = []
var _selectedAbility: Ability = null
var _hasConfirmedAttrs: bool = false


func _ready() -> void:
	%LevelLabel.text = "Level: %d" % stats.level
	%XpLabel.text = "Exp: %d" % stats.currentXp
	%NextLevelLabel.text = "Next Level: %d" % stats.xpRemaining
	_buildStatControls()

	%ConfirmBtn.connect("button_up", _confirmChoices)
	reroll.connect("button_up", _rerollAbilities)

func _setupAbilityCards() -> void:
	var rngAbilities: Array[Ability] = _getRandomAbilities()

	for idx in rngAbilities.size():
		var card: Control = load("res://Scenes/UI/AbilityCard.tscn").instantiate()
		card.ability = rngAbilities[idx]
		card.position = Vector2(12 + (idx * 100), 32)
		card.z_index = 10
		card.connect("select", _handleAbilitySelect)
		card.connect("deselect", _deselectAbility)
		_cards.push_back(card)
		canvas_layer.add_child(card)

func _getRandomAbilities() -> Array[Ability]:
	var abilities: Array[Ability] = []

	for i in 3:
		var ability: Ability = _allAbilities.resource_list.filter(func(a: Ability): return !abilities.has(a) && a.name).pick_random()
		abilities.push_back(ability)

	return abilities

func _rerollAbilities() -> void:
	for card in _cards:
		card.disconnect("select", _handleAbilitySelect)
		card.disconnect("deselect", _deselectAbility)
		card.queue_free()

	_cards = []
	_setupAbilityCards()
	_deselectAbility()

func _buildStatControls() -> void:
	for key in _statNameStrings:
		%StatsBox.add_child(_buildControlRow(key))

func _buildControlRow(key: String) -> GridContainer:
	var c: GridContainer = GridContainer.new()
	c.columns = 2
	# Label
	var l: Label = Label.new()
	l.theme = preload("res://Themes/Base.tres")
	l.name = "%s_label" % key
	l.text = "%s: %d+%d" % [_statNameStrings[key], stats[key], _statsLocal[key]]
	c.add_child(l)
	# Box
	var hBox: HBoxContainer = HBoxContainer.new()
	hBox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Buttons
	var minus: TextureButton = TextureButton.new()
	var plus: TextureButton = TextureButton.new()
	minus.texture_normal = load("res://Assets/white-square.png")
	minus.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT
	minus.ignore_texture_size = true
	minus.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	minus.modulate = Color(0.8, 0.165, 0.3)
	minus.connect("button_up", func(): _handleStatChange(key, -1))
	#
	plus.texture_normal = load("res://Assets/white-square.png")
	plus.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT
	plus.ignore_texture_size = true
	plus.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	plus.modulate = Color(0.0, 0.57, 0.31)
	plus.connect("button_up", func(): _handleStatChange(key, 1))
	#
	hBox.add_child(minus)
	hBox.add_child(plus)
	c.add_child(hBox)

	return c

func _handleStatChange(key: String, value: int) -> void:
	if value > 0 && _pointsAvail <= 0:
		return

	if _statsLocal[key] + value < 0:
		print("Adding %d to %d is less than 0" % [value, _statsLocal[key]])
		return

	_statsLocal[key] += value
	_pointsAvail -= value
	_updateLabel(key)
	_updatePoints()

func _updatePoints() -> void:
	%PointsAvail.text = "Points Available: %d" % _pointsAvail

func _updateLabel(key: String) -> void:
	var label: Label = _getStatLabel(key)
	label.text = "%s: %d+%d" % [_statNameStrings[key], stats[key], _statsLocal[key]]

func _getStatLabel(key: String) -> Label:
	var labelName: String = "%s_label" % key
	var label: Label

	for gc in %StatsBox.get_children():
		if !gc is GridContainer:
			continue
		if gc.has_node(labelName):
			label = gc.get_node(labelName)
			break

	return label

func _confirmChoices() -> void:
	if !_hasConfirmedAttrs:
		_setupAbilityCards()
		reroll.show()
		%StatsBox.hide()
		%ConfirmBtn.text = 'Confirm'
		_hasConfirmedAttrs = true
		return

	# @TODO: A better way to validate this + error messaging
	if !_selectedAbility || _pointsAvail > 0:
		return

	var updates: Dictionary = {
		"ability": _selectedAbility,
		"stats": {},
	}

	for key in _statsLocal:
		updates.stats[key] = stats[key] + _statsLocal[key]

	confirm_choices.emit(updates)

func _handleAbilitySelect(ability: Ability) -> void:
	_selectedAbility = ability

	for card in _cards:
		if card.ability != _selectedAbility:
			card.handleExit(false)

func _deselectAbility() -> void:
	_selectedAbility = null
