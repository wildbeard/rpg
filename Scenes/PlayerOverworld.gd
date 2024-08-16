extends CharacterBody2D

signal toggle_inventory()

const ACCELERATION: float = 500.0
const SPEED: float = 100.0

@export var inventoryData: InventoryData

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input: Vector2
	input.x = Input.get_axis("move_left", "move_right")
	input.y = Input.get_axis("move_up", "move_down")
	
	if input != Vector2.ZERO:
		velocity = velocity.move_toward(input.normalized() * SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, ACCELERATION * delta)

	move_and_slide()

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		toggle_inventory.emit()
