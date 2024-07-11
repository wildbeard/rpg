extends Node2D

signal switch_scene(scene: Node)

@onready var player = $CharacterBody2D
@onready var inventoryUI = $CanvasLayer/InventoryUI
@onready var equpmentInventory = $CanvasLayer/InventoryUI/EqupmentInventory
@onready var grabbedSlot = $CanvasLayer/InventoryUI/GrabbedSlot
@onready var button = $Button

func _ready() -> void:
	self.inventoryUI.setPlayerInventory(self.player.inventoryData)
	self.player.connect("toggle_inventory", togglePlayerInventory)
	self.button.pressed.connect(_switchScene)

func togglePlayerInventory() -> void:
	self.inventoryUI.visible = !self.inventoryUI.visible

func _switchScene() -> void:
	var s: Node = preload("res://Scenes/Battle/BattleScene.tscn").instantiate()
	switch_scene.emit(s)
