extends Control
class_name EndBattleModal

var battleStats: Dictionary = {
	"test": 123
}

func _ready():
	for key in self.battleStats:
		%BattleStatsList.add_item("%s: %d" % [key, self.battleStats[key]])
