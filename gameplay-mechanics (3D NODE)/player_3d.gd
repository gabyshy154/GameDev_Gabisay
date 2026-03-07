extends CharacterBody3D

@export_group("Movement")
@export var move_speed := 8.0
@export var acceleration := 20.0
@export var jump_impulse := 12.0
@export var rotation_speed := 12.0
@export var stopping_speed := 1.0

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export var tilt_upper_limit := PI / 3.0
@export var tilt_lower_limit := -PI / 8.0

# Respawn settings
const FALL_LIMIT = -10.0
var spawn_position = Vector3.ZERO

var _gravity := -30.0
var _camera_input_direction := Vector2.ZERO
var _was_on_floor_last_frame := true

@onready var _last_input_direction := global_basis.z
@onready var _camera_pivot: Node3D = $CameraPivot
@onready var _camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var _skin: SophiaSkin = $SophiaSkin

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	var spawn_point = get_tree().get_first_node_in_group("spawn_point")
	if spawn_point:
		spawn_position = spawn_point.global_position
	else:
		spawn_position = global_position

	global_position = spawn_position

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	var player_is_using_mouse := (
		event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if player_is_using_mouse:
		_camera_input_direction.x = -event.relative.x * mouse_sensitivity
		_camera_input_direction.y = -event.relative.y * mouse_sensitivity

func _physics_process(delta: float) -> void:
	# 1. Rotate camera pivot with mouse
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, tilt_lower_limit, tilt_upper_limit)
	_camera_pivot.rotation.y += _camera_input_direction.x * delta
	_camera_input_direction = Vector2.ZERO

	# 2. Calculate movement direction relative to camera
	var raw_input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward", 0.4)
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()

	# 3. Rotate skin smoothly toward movement direction
	if move_direction.length() > 0.2:
		_last_input_direction = move_direction.normalized()
	var target_angle := Vector3.BACK.signed_angle_to(_last_input_direction, Vector3.UP)
	_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)

	# 4. Apply movement with acceleration
	var y_velocity := velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	if is_equal_approx(move_direction.length_squared(), 0.0) and velocity.length_squared() < stopping_speed:
		velocity = Vector3.ZERO
	velocity.y = y_velocity + _gravity * delta

	# 5. Jump
	var is_just_jumping := Input.is_action_just_pressed("ui_accept") and is_on_floor()
	if is_just_jumping:
		velocity.y += jump_impulse
		_skin.jump()  # ← play jump animation

	# 6. Play animations based on state
	var ground_speed := Vector2(velocity.x, velocity.z).length()

	if not is_on_floor() and velocity.y < 0:
		_skin.fall()               # ← falling animation
	elif is_on_floor():
		if ground_speed > stopping_speed:
			_skin.move()           # ← run animation
		else:
			_skin.idle()           # ← idle animation

	_was_on_floor_last_frame = is_on_floor()
	move_and_slide()

	# 7. Fall detection → respawn
	if global_position.y < FALL_LIMIT:
		respawn()

func respawn() -> void:
	velocity = Vector3.ZERO
	global_position = spawn_position
	_skin.idle()  # ← reset to idle on respawn
