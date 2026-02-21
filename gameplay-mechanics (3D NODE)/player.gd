extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 6.0
const GRAVITY = 15.0

func _physics_process(delta):
	# 1. Apply gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# 2. Jump with Spacebar
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. Move with Arrow keys / WASD
	var input_dir = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)

	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()

	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
