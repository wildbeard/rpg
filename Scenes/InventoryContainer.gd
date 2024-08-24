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
			self.container_opened.emit(self)
			self.sprite.texture = self.opened_sprite
		else:
			self.container_closed.emit()
			self.sprite.texture = self.closed_sprite

var _in_area: bool = false

func _ready() -> void:
	self.sprite.texture = self.closed_sprite
	#
	self.openArea.body_entered.connect(self._on_body_entered)
	self.openArea.body_exited.connect(self._on_body_exited)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") && self._in_area:
		self.is_open = !self.is_open

func _on_body_entered(body: Node2D) -> void:
	if body is OverworldPlayer:
		self.openLabel.visible = true
		self._in_area = true

func _on_body_exited(body: Node2D) -> void:
	if body is OverworldPlayer:
		self.openLabel.visible = false
		self._in_area = false
