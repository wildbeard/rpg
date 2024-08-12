extends Node

signal player_updated(m: Node)

var player: PlayerCharacter
var inventory: InventoryData
var stats: PlayerStats

func _ready():
	# Ugh, globals
	self.player = preload("res://Scenes/PlayerCharacter.tscn").instantiate()
	self.inventory = preload("res://Resources/Inventory/PlayerInventory.tres")
	self.inventory.inventory_updated.connect(func(_d): player_updated.emit())

	self.stats = self.player.characterStats
	self.stats.levelUp.connect(func(): player_updated.emit())

func getEquippedItems() -> Dictionary:
	return self.inventory.equipment

func getAbilityBook() -> CharacterAbilityBook:
	return self.player.abilityBook
