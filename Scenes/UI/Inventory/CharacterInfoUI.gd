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
	_updateUI()

func _updateUI() -> void:
	_updateStats()
	_updateAttributes()

func _updateStats() -> void:
	physPowerValue.text = str(PlayerManager.stats.getPhysicalPower())
	physDefValue.text = str(PlayerManager.stats.getPhysicalDef())
	mgkPowerValue.text = str(PlayerManager.stats.getMagicalPower())
	mgkDefValue.text = str(PlayerManager.stats.getMagicalDef())

func _updateAttributes() -> void:
	var stats: PlayerStats = PlayerManager.stats

	vitalityValue.text = str(stats.vitality + stats.getEquipmentAttributes("vitality"))
	strengthValue.text = str(stats.strength + stats.getEquipmentAttributes("strength"))
	intelligenceValue.text = str(stats.intelligence + stats.getEquipmentAttributes("intelligence"))
	wisdomValue.text = str(stats.wisdom + stats.getEquipmentAttributes("wisdom"))
	dexterityValue.text = str(stats.dexterity + stats.getEquipmentAttributes("dexterity"))
