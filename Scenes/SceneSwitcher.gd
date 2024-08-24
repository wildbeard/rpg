extends Node2D

const DEFAULT_SCENE: PackedScene = preload("res://Scenes/Overworld.tscn")

var currentScene

func _ready() -> void:
	currentScene = DEFAULT_SCENE.instantiate()
	currentScene.connect("switch_scene", _on_switch_scene)
	add_child(currentScene)

func _on_switch_scene(scene) -> void:
	currentScene.queue_free()
	currentScene = scene

	if currentScene.has_signal("switch_scene"):
		currentScene.connect("switch_scene", _on_switch_scene)

	add_child(currentScene)
