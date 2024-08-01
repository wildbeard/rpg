extends Control

@export var ability: Ability

@onready var ability_icon = $AbilityIcon
@onready var ability_name = $AbilityName
@onready var ability_description = $AbilityDescription
@onready var ability_element = $AbilityElement
@onready var cooldown = $Cooldown

func _ready() -> void:
	self.ability_name.text = ability.name
	self.ability_icon.texture = self.ability.icon
	self.ability_description.text = self._getDescription()
	self.ability_element.text = "Element: %s" % self._getElementType()
	self.cooldown.text = "CD: %d" % self.ability.cooldown

func _getDescription() -> String:
	var input: String = self.ability.description

	if !input:
		input = 'Deals %bd(+%dmgMod) %dt damage.'

	var descKeys: Dictionary = {
		'%bd': func(): return self.ability.damage_base,
		'%dmgMod': self._getDamageModifier,
		'%dt': func(): return 'Physical' if Ability.DamageType.PHYSICAL == self.ability.damage_type else 'Magic',
		'%et': self._getElementType,
		'%h': func(): return self.ability.number_of_hits
	}

	for key in descKeys:
		input = input.replace(key, str(descKeys[key].call()))

	return input

func _getDamageModifier() -> int:
	var stats: float = self.ability.getDamageFromStats(PlayerManager.stats)
	var equip: float = self.ability.getDamageFromEquipment(PlayerManager.getEquippedItems())

	return roundi(stats + equip)

func _getElementType() -> String:
	var elType: String = Ability.ElementType.keys()[self.ability.element_type].capitalize()
	return elType if elType != 'None' else 'N/A'
