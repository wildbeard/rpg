extends Node2D

const DEFAULT_SCENE: PackedScene = preload("res://Scenes/Overworld.tscn")

var currentScene: Node
var nextScene: Node

func _ready() -> void:
	self.currentScene = DEFAULT_SCENE.instantiate()
	self.currentScene.connect("switch_scene", _on_switch_scene)
	add_child(self.currentScene)

func _on_switch_scene(scene: Node) -> void:
	self.nextScene = scene
	self._switchScene()

func _switchScene() -> void:
	self.currentScene.queue_free()
	self.currentScene = self.nextScene
	self.nextScene = null

	if self.currentScene.has_signal("switch_scene"):
		self.currentScene.connect("switch_scene", _on_switch_scene)

	add_child(self.currentScene)
