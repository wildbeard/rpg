extends Node2D

signal switch_scene(scene: Node)

@onready var player: OverworldPlayer = $OverworldPlayer
@onready var enterBattleBtn: Button = $CanvasLayer/EnterBattleBtn
@onready var enemy: GoblinWizard = $GoblinWizard
@onready var chest: InventoryContainer = $Chest
@onready var inventoryWrapper: InventoryUI = $CanvasLayer/InventoryUI/PanelContainer/MarginContainer/InventeryWrapper

func _ready() -> void:
	self.inventoryWrapper.setPlayerInventory(self.player.inventoryData)
	self.player.connect("toggle_inventory", togglePlayerInventory)
	self.enterBattleBtn.pressed.connect(_switchScene)
	self.enemy.connect("start_battle", self._on_start_battle)
	#
	self.chest.container_opened.connect(self._on_container_opened)
	self.chest.container_closed.connect(self._on_container_closed)

func togglePlayerInventory(inventoryOnly: bool = false) -> void:
	enterBattleBtn.visible = !enterBattleBtn.visible
	%InventoryUI.visible = !%InventoryUI.visible

	if inventoryOnly:
		inventoryWrapper.toggleInventory()
		inventoryWrapper.toggleExternal()
	else:
		inventoryWrapper.toggleInventory()
		inventoryWrapper.toggleEquipment()

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

func _on_container_opened(invContainer: InventoryContainer) -> void:
	inventoryWrapper.setExternalInventory(invContainer.inventory_data)
	self.togglePlayerInventory(true)

func _on_container_closed() -> void:
	togglePlayerInventory(true)
