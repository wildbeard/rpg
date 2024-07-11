extends Control

@onready var vitalityValue = $PanelContainer/Control/MarginContainer/VBoxContainer/Attributes/VBoxContainer/HBoxContainer/VitalityValue
@onready var strengthValue = $PanelContainer/Control/MarginContainer/VBoxContainer/Attributes/VBoxContainer/HBoxContainer2/StrengthValue
@onready var intelligenceValue = $PanelContainer/Control/MarginContainer/VBoxContainer/Attributes/VBoxContainer/HBoxContainer3/IntelligenceValue
@onready var wisdomValue = $PanelContainer/Control/MarginContainer/VBoxContainer/Attributes/VBoxContainer/HBoxContainer4/WisdomValue
@onready var dexterityValue = $PanelContainer/Control/MarginContainer/VBoxContainer/Attributes/VBoxContainer/HBoxContainer5/DexterityValue
@onready var attack_stat = $PanelContainer/Control/MarginContainer/VBoxContainer/Stats/AttackStat

# Called when the node enters the scene tree for the first time.
func _ready():
	self.vitalityValue.text = str(PlayerManager.stats.vitality)
	self.strengthValue.text = str(PlayerManager.stats.strength)
	self.intelligenceValue.text = str(PlayerManager.stats.intelligence)
	self.wisdomValue.text = str(PlayerManager.stats.wisdom)
	self.dexterityValue.text = str(PlayerManager.stats.dexterity)

	self.attack_stat.text = "Attack: %d" % PlayerManager.stats.getAttackPower()
