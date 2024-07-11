extends Control

@onready var vitalityValue = $PanelContainer/Control/MarginContainer/VBoxContainer/Attributes/VBoxContainer/HBoxContainer/VitalityValue
@onready var strengthValue = $PanelContainer/Control/MarginContainer/VBoxContainer/Attributes/VBoxContainer/HBoxContainer2/StrengthValue
@onready var intelligenceValue = $PanelContainer/Control/MarginContainer/VBoxContainer/Attributes/VBoxContainer/HBoxContainer3/IntelligenceValue
@onready var wisdomValue = $PanelContainer/Control/MarginContainer/VBoxContainer/Attributes/VBoxContainer/HBoxContainer4/WisdomValue
@onready var dexterityValue = $PanelContainer/Control/MarginContainer/VBoxContainer/Attributes/VBoxContainer/HBoxContainer5/DexterityValue
@onready var attackValue = $PanelContainer/Control/MarginContainer/VBoxContainer/Stats/VBoxContainer/HBoxContainer/AttackValue
@onready var defenseValue = $PanelContainer/Control/MarginContainer/VBoxContainer/Stats/VBoxContainer/HBoxContainer2/DefenseValue


# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerManager.player_updated.connect(_updateUI)
	self._updateUI()

func _updateUI() -> void:
	print("Updating UI")
	self._updateStats()
	self._updateAttributes()

func _updateStats() -> void:
	self.attackValue.text = str(PlayerManager.stats.getAttackPower())
	self.defenseValue.text = str(PlayerManager.stats.getArmorRating())

func _updateAttributes() -> void:
	self.vitalityValue.text = str(PlayerManager.stats.vitality)
	self.strengthValue.text = str(PlayerManager.stats.strength)
	self.intelligenceValue.text = str(PlayerManager.stats.intelligence)
	self.wisdomValue.text = str(PlayerManager.stats.wisdom)
	self.dexterityValue.text = str(PlayerManager.stats.dexterity)
