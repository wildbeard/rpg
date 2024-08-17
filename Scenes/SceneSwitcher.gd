extends Node2D

const DEFAULT_SCENE: PackedScene = preload("res://Scenes/Overworld.tscn")

var currentScene

func _ready() -> void:
	self.currentScene = DEFAULT_SCENE.instantiate()
	self.currentScene.connect("switch_scene", _on_switch_scene)
	add_child(self.currentScene)

func _on_switch_scene(scene) -> void:
	var nextScene = scene
	self.currentScene.queue_free()
	self.currentScene = scene

	if self.currentScene.has_signal("switch_scene"):
		self.currentScene.connect("switch_scene", self._on_switch_scene)

	add_child(self.currentScene)
