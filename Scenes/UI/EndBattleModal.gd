extends Control
class_name EndBattleModal

signal restart()

var battleStatsText: Dictionary = {
	"damage_dealt": "Damage Dealt",
	"damage_taken": "Damage Taken",
	"damage_healed": "Damage Healed",
	"highest_hit": "Highest Hit",
	"xp_gained": "XP Gained",
	"xp_remaining": "XP to next Level"
}
var battleStats: Dictionary = {
	"damage_dealt": 100,
	"damage_taken": 50,
	"damage_healed": 0,
	"highest_hit": 10,
	"xp_gained": 150,
	"xp_remaining": 25
}

func _ready():
	for key in self.battleStats:
		if self.battleStatsText.has(key):
			%BattleStatsList.add_item("%s: %d" % [self.battleStatsText[key], self.battleStats[key]])

	%GoAgain.connect("button_up", func(): self.restart.emit())
