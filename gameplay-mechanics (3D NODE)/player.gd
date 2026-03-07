extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 6.0
const GRAVITY = 15.0

# Camera rotation variables
var camera_rotation_x = -20.0
var camera_rotation_y = 0.0
const MOUSE_SENSITIVITY = 0.3

# Respawn settings
const FALL_LIMIT = -10.0  # if player Y goes below this, respawn
var spawn_position = Vector3.ZERO

@onready var spring_arm = $SpringArm3D

func _ready():
	# Lock and hide mouse cursor for camera control
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Find the SpawnPoint node in the scene and save its position
	var spawn_point = get_tree().get_first_node_in_group("spawn_point")
	if spawn_point:
		spawn_position = spawn_point.global_position
	else:
		# Fallback: use wherever the player starts
		spawn_position = global_position
	
	# Place player at spawn on start
	global_position = spawn_position

func _input(event):
	# Rotate camera with mouse movement
	if event is InputEventMouseMotion:
		camera_rotation_y -= event.relative.x * MOUSE_SENSITIVITY
		camera_rotation_x -= event.relative.y * MOUSE_SENSITIVITY
		camera_rotation_x = clamp(camera_rotation_x, -60, 10)
		spring_arm.rotation_degrees.x = camera_rotation_x
		rotation_degrees.y = camera_rotation_y

	# Press Escape to free the mouse
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	# 1. Apply gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# 2. Jump with Spacebar
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. Move with WASD or Arrow Keys
	var input_dir = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_forward", "move_backward")
	)

	var forward = -transform.basis.z
	var right = transform.basis.x
	var direction = (forward * -input_dir.y + right * input_dir.x).normalized()

	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	# 4. Check if player fell off the map
	if global_position.y < FALL_LIMIT:
		respawn()

func respawn():
	# Reset velocity so player doesn't keep falling speed on respawn
	velocity = Vector3.ZERO
	# Teleport back to spawn point
	global_position = spawn_position
