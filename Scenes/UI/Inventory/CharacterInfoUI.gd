extends Control

@onready var vitalityValue = $PanelContainer/Control/MarginContainer/VBoxContainer/Attributes/VBoxContainer/HBoxContainer/VitalityValue
@onready var strengthValue = $PanelContainer/Control/MarginContainer/VBoxContainer/Attributes/VBoxContainer/HBoxContainer2/StrengthValue
@onready var intelligenceValue = $PanelContainer/Control/MarginContainer/VBoxContainer/Attributes/VBoxContainer/HBoxContainer3/IntelligenceValue
@onready var wisdomValue = $PanelContainer/Control/MarginContainer/VBoxContainer/Attributes/VBoxContainer/HBoxContainer4/WisdomValue
@onready var dexterityValue = $PanelContainer/Control/MarginContainer/VBoxContainer/Attributes/VBoxContainer/HBoxContainer5/DexterityValue
@onready var physPowerValue = $PanelContainer/Control/MarginContainer/VBoxContainer/Stats/VBoxContainer/HBoxContainer/PhysPowerValue
@onready var physDefValue = $PanelContainer/Control/MarginContainer/VBoxContainer/Stats/VBoxContainer/HBoxContainer2/PhysDefValue
@onready var mgkPowerValue = $PanelContainer/Control/MarginContainer/VBoxContainer/Stats/VBoxContainer/HBoxContainer3/MgkPowerValue
@onready var mgkDefValue = $PanelContainer/Control/MarginContainer/VBoxContainer/Stats/VBoxContainer/HBoxContainer4/MgkDefValue

func _ready():
	PlayerManager.player_updated.connect(_updateUI)
	self._updateUI()

func _updateUI() -> void:
	self._updateStats()
	self._updateAttributes()

func _updateStats() -> void:
	self.physPowerValue.text = str(PlayerManager.stats.getPhysicalPower())
	self.physDefValue.text = str(PlayerManager.stats.getPhysicalDef())
	self.mgkPowerValue.text = str(PlayerManager.stats.getMagicalPower())
	self.mgkDefValue.text = str(PlayerManager.stats.getMagicalDef())

func _updateAttributes() -> void:
	var stats: PlayerStats = PlayerManager.stats

	self.vitalityValue.text = str(stats.vitality + stats.getEquipmentAttributes("vitality"))
	self.strengthValue.text = str(stats.strength + stats.getEquipmentAttributes("strength"))
	self.intelligenceValue.text = str(stats.intelligence + stats.getEquipmentAttributes("intelligence"))
	self.wisdomValue.text = str(stats.wisdom + stats.getEquipmentAttributes("wisdom"))
	self.dexterityValue.text = str(stats.dexterity + stats.getEquipmentAttributes("dexterity"))
