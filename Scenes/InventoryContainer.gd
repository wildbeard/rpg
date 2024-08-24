extends StaticBody2D
class_name InventoryContainer

signal container_opened(chest: InventoryContainer)
signal container_closed()

@export var inventory_data: InventoryData
@export var closed_sprite: Texture2D
@export var opened_sprite: Texture2D

@onready var sprite: Sprite2D = $Sprite
@onready var openArea: Area2D = $Area2D
@onready var openLabel: Label = $CanvasLayer/OpenLabel

var is_open: bool = false:
	set(open):
		is_open = open

		if open:
			container_opened.emit(self)
			sprite.texture = opened_sprite
		else:
			container_closed.emit()
			sprite.texture = closed_sprite

var _in_area: bool = false

func _ready() -> void:
	sprite.texture = closed_sprite
	#
	openArea.body_entered.connect(_on_body_entered)
	openArea.body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") && _in_area:
		is_open = !is_open

func _on_body_entered(body: Node2D) -> void:
	if body is OverworldPlayer:
		openLabel.visible = true
		_in_area = true

func _on_body_exited(body: Node2D) -> void:
	if body is OverworldPlayer:
		openLabel.visible = false
		_in_area = false
