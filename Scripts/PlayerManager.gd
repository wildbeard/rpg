extends Node

signal player_updated(m: Node)

var inventory: InventoryData
var stats: PlayerStats

# Called when the node enters the scene tree for the first time.
func _ready():
	self.inventory = preload("res://Resources/Inventory/PlayerInventory.tres")
	self.inventory.inventory_updated.connect(func(_d): player_updated.emit())

	self.stats = PlayerStats.new()
	self.stats.levelUp.connect(func(): player_updated.emit())

func getEquippedItems() -> Dictionary:
	return self.inventory.equipment
