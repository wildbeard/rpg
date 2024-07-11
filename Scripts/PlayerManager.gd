extends Node

var inventory: InventoryData
var stats: PlayerStats

# Called when the node enters the scene tree for the first time.
func _ready():
	self.inventory = preload("res://Resources/Inventory/PlayerInventory.tres")
	self.stats = PlayerStats.new()

func getEquippedItems() -> Dictionary:
	return self.inventory.equipment
