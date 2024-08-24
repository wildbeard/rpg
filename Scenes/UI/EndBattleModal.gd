extends Control
class_name EndBattleModal

signal restart()

var battleStatsText: Dictionary = {
	"damage_dealt": "Damage Dealt",
	"damage_taken": "Damage Taken",
	"damage_healed": "Damage Healed",
	"highest_hit": "Highest Hit",
	"xp_gained": "XP Gained",
	"xp_remaining": "XP to next Level",
	"enemies_killed": "Enemies Killed",
	"gold_earned": "Gold Earned",
}
var battleStats: Dictionary = {
	"damage_dealt": 100,
	"damage_taken": 50,
	"damage_healed": 0,
	"highest_hit": 10,
	"xp_gained": 150,
	"xp_remaining": 25,
	"enemies_killed": 1,
	"gold_earned": 25,
	"item_rewards": [],
}

func _ready():
	self._updatePlayerGold(self.battleStats.gold_earned)
	%TotalGoldLabel.text = 'Total Gold: %d' % (self._getTotalGold())

	if self.battleStats.item_rewards.size():
		var item: Item = self.battleStats.item_rewards[0]
		%ItemNameLabel.text = item.name
		%ItemTexture.texture = item.texture

		if item is Armor:
			%ItemDescLabel.text = "Phys. Def: +%d\n" % item.physicalDefense
			%ItemDescLabel.text += "Mgk. Def: +%d\n" % item.magicalDefense
			for modKey in item.statModifiers.keys().filter(func(k: String): return item.statModifiers[k] != 0):
				%ItemDescLabel.text += "%s: +%d\n" % [modKey.to_upper(), item.statModifiers[modKey]]
		elif item is Weapon:
			%ItemDescLabel.text = "Phys. Dmg: +%d\n" % item.physicalDamage
			%ItemDescLabel.text += "Mgk. Dmg: +%d\n" % item.magicalDamage
			for modKey in item.statModifiers.keys().filter(func(k: String): return item.statModifiers[k] != 0):
				%ItemDescLabel.text += "%s: +%d\n" % [modKey.to_upper(), item.statModifiers[modKey]]
		else:
			%ItemDescLabel.text = item.description

	%GoAgain.connect("button_up", func(): self.restart.emit())

func _getTotalGold() -> int:
	var total: int = 0
	var foundData: Array[SlotData] = PlayerManager.inventory.data.filter(func(sd: SlotData): return sd && sd.item.name == 'Coins')

	for sd in foundData:
		total += sd.quantity

	return total

# @TODO: I don't think this should be the responsibility of this class. Move to Inventory.
func _updatePlayerGold(income: int) -> void:
	var remaining: int = income
	var foundData: Array[SlotData] = PlayerManager.inventory.data.filter(func(sd: SlotData): return sd && sd.item.name == 'Coins')
	
	while remaining > 0:
		for sd in foundData:
			if sd.quantity + remaining < sd.item.maxStack:
				sd.quantity += remaining
				remaining = 0
			else:
				var used: int = remaining - (sd.item.maxStack - sd.quantity)
				remaining -= used
				sd.quantity = sd.item.maxStack

		var emptySlotIdx: int = PlayerManager.inventory.data.find(null)

		if remaining > 0 && emptySlotIdx > -1:
			var sd: SlotData = SlotData.new()
			sd.item = load("res://Resources/Items/Coin.tres")
			sd.quantity = remaining
		elif remaining > 0 && emptySlotIdx == -1:
			push_warning("No slots for gold. Losing %d" % remaining)
			remaining = 0
		elif remaining > 0:
			push_warning("Infinite Breaker; Remaining: %d" % remaining)
			remaining = 0
