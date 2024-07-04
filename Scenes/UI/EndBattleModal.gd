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
var battleStats: Dictionary = {}

func _ready():
	for key in self.battleStats:
		if self.battleStatsText.has(key):
			%BattleStatsList.add_item("%s: %d" % [self.battleStatsText[key], self.battleStats[key]])

	%GoAgain.connect("button_up", self._restart)

func _restart() -> void:
	queue_free()
	restart.emit()
