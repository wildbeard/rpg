extends CharacterBody2D

const ACCELERATION: float = 1000.0
const SPEED: float = 300.0

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
