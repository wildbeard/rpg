extends Node
class_name CharacterStats

@export var baseHp: int = 10
@export var baseMp: int = 100
@export var level: int = 1

# 10 * level HP + stats
var maxHp: int = baseHp:
	get:
		# @todo: Make vitality less useful as it is levelled
		var fromStats: int = ceili(self.vitality * 1)
		var fromLevels: int = (0 if self.level == 1 else 10) * (self.level - 1)
		return baseHp + fromStats + fromLevels

var strength: int = 5
var intelligence: int = 5
var wisdom: int = 5
var dexterity: int = 5
var speed: int = 5 # Speed
var vitality: int = 10 # HP
