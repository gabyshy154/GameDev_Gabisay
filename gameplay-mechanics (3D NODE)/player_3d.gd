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

const FALL_LIMIT = -10.0
var spawn_position := Vector3.ZERO

var _gravity := -30.0
var _camera_input_direction := Vector2.ZERO
var _was_on_floor_last_frame := true

@onready var _last_input_direction := global_basis.z
@onready var _camera_pivot: Node3D = $CameraPivot
@onready var _camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var _skin: SophiaSkin = $SophiaSkin

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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
	# Camera rotation
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, tilt_lower_limit, tilt_upper_limit)
	_camera_pivot.rotation.y += _camera_input_direction.x * delta
	_camera_input_direction = Vector2.ZERO

	# Movement direction
	var raw_input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward", 0.4)
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()

	# Rotation
	if move_direction.length() > 0.2:
		_last_input_direction = move_direction.normalized()

	var target_angle := Vector3.BACK.signed_angle_to(_last_input_direction, Vector3.UP)
	_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)

	# Movement physics
	var y_velocity := velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)

	if is_equal_approx(move_direction.length_squared(), 0.0) and velocity.length_squared() < stopping_speed:
		velocity = Vector3.ZERO

	velocity.y = y_velocity + _gravity * delta

	# === SOUND LOGIC ===

	# Jump - Only play jump sound here
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_impulse
		_skin.jump()
		AudioManager.play_sfx(AudioManager.sfx_jump) 

	# Animations
	var ground_speed := Vector2(velocity.x, velocity.z).length()

	if not is_on_floor() and velocity.y < 0:
		_skin.fall()
	elif is_on_floor():
		if ground_speed > stopping_speed:
			_skin.move()
		else:
			_skin.idle()

	_was_on_floor_last_frame = is_on_floor()
	move_and_slide()

	# Respawn
	if global_position.y < FALL_LIMIT:
		respawn()

func respawn() -> void:
	velocity = Vector3.ZERO
	global_position = spawn_position
	_skin.idle()
