extends Node2D

signal switch_scene(scene: Node)

@onready var player: OverworldPlayer = $OverworldPlayer
#@onready var equpmentInventory = $CanvasLayer/InventoryUI/EqupmentInventory
#@onready var grabbedSlot = $CanvasLayer/InventoryUI/GrabbedSlot
#@onready var button = $CanvasLayer/Button
@onready var playerInventory: PlayerInventory = $CanvasLayer/InventoryUI/PanelContainer/MarginContainer/Inventory
@onready var enemy: GoblinWizard = $GoblinWizard

func _ready() -> void:
	self.playerInventory.setPlayerInventory(self.player.inventoryData)
	self.player.connect("toggle_inventory", togglePlayerInventory)
	#self.button.pressed.connect(_switchScene)
	self.enemy.connect("start_battle", self._on_start_battle)

func togglePlayerInventory() -> void:
	%InventoryUI.visible = !%InventoryUI.visible
	# self.button.visible = !self.inventoryUI.visible

func _switchScene() -> void:
	var s: Node = preload("res://Scenes/Battle/BattleScene.tscn").instantiate()
	self.switch_scene.emit(s)

func _on_start_battle(enemies: Array[Enemy]) -> void:
	var scene: BattleScene = preload("res://Scenes/Battle/BattleScene.tscn").instantiate()

	for e in enemies:
		if self.get_children().has(e):
			call_deferred("_remove_enemy", e)

	scene.enemies = enemies
	self.switch_scene.emit(scene)

func _remove_enemy(e: Enemy) -> void:
	self.remove_child(e)
