extends Node2D

@onready var player = $CharacterBody2D
@onready var inventoryUI = $CanvasLayer/InventoryUI
@onready var grabbedSlot = $CanvasLayer/InventoryUI/GrabbedSlot

func _ready() -> void:
	self.inventoryUI.setPlayerInventory(self.player.inventoryData)
	self.player.connect("toggle_inventory", togglePlayerInventory)

func togglePlayerInventory() -> void:
	self.inventoryUI.visible = !self.inventoryUI.visible
