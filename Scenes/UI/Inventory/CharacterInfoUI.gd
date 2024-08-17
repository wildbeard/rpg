extends Control

@onready var vitalityValue = %VitalityVal
@onready var strengthValue = %StrengthVal
@onready var intelligenceValue = %IntelligenceVal
@onready var wisdomValue = %WisdomVal
@onready var dexterityValue = %DextiertyVal
@onready var physPowerValue = %PhysDamVal
@onready var physDefValue = %PhysDefVal
@onready var mgkPowerValue = %MgkDmgVal
@onready var mgkDefValue = %MgkDefVal

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
