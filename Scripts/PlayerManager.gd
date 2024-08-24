extends Node

signal player_updated(m: Node)

var player: PlayerCharacter
var inventory: InventoryData
var stats: PlayerStats

func _ready():
	# Ugh, globals
	player = preload("res://Scenes/PlayerCharacter.tscn").instantiate()
	inventory = preload("res://Resources/Inventory/PlayerInventory.tres")
	inventory.inventory_updated.connect(func(_d): player_updated.emit())

	stats = player.characterStats
	stats.levelUp.connect(func(): player_updated.emit())

func getEquippedItems() -> Dictionary:
	return inventory.equipment

func getAbilityBook() -> CharacterAbilityBook:
	return player.abilityBook
