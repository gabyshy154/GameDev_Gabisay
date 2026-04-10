extends CharacterBody3D

@export var speed: float = 7.0
@export var catch_distance: float = 1.6
@export var jump_threshold: float = 0.8
@export var max_jump_velocity: float = 14.0
@export var min_jump_velocity: float = 6.0
@export var path_update_interval: float = 0.15
@export var detection_range: float = 999.0
@export var sight_range: float = 999.0

var spawn_position := Vector3.ZERO
var player: Node3D = null
var is_chasing := false
var _ready_done := false

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _path_timer: float = 0.0

var _last_position := Vector3.ZERO
var _stuck_timer: float = 0.0
const STUCK_THRESHOLD = 0.4
const STUCK_MIN_MOVE = 0.3
const FALL_LIMIT = -10.0

var _dead := false

@onready var nav: NavigationAgent3D = $NavigationAgent3D

func _ready():
	await get_tree().create_timer(1.5).timeout
	player = get_tree().get_first_node_in_group("player")
	nav.path_desired_distance = 0.5
	nav.target_desired_distance = 0.5
	_last_position = global_position
	spawn_position = global_position
	_ready_done = true

func _physics_process(delta: float) -> void:
	if not _ready_done:
		return

	if _dead:
		return

	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return

	if global_position.y < FALL_LIMIT:
		global_position = spawn_position
		velocity = Vector3.ZERO
		is_chasing = false
		return

	var dist = global_position.distance_to(player.global_position)
	if not is_chasing:
		if dist < detection_range:
			is_chasing = true
		elif dist < sight_range and _can_see_player():
			is_chasing = true

	if not is_chasing:
		if not is_on_floor():
			velocity.y -= _gravity * delta
		else:
			velocity.x = 0.0
			velocity.z = 0.0
			velocity.y = -1.0
		move_and_slide()
		return

	# === CHASING LOGIC ===
	var height_diff: float = player.global_position.y - global_position.y

	_path_timer += delta
	if _path_timer >= path_update_interval:
		_path_timer = 0.0
		nav.target_position = player.global_position

	var next_pos: Vector3 = nav.get_next_path_position()
	var dir: Vector3
	if abs(height_diff) > 0.6:
		dir = player.global_position - global_position
	else:
		dir = next_pos - global_position

	dir.y = 0.0
	if dir.length() > 0.1:
		dir = dir.normalized()

	if dir.length() > 0.1:
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
		var look_target = global_position + dir
		look_at(look_target, Vector3.UP)
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)
		velocity.z = move_toward(velocity.z, 0.0, speed)

	if is_on_floor():
		_stuck_timer += delta
		if global_position.distance_to(_last_position) > STUCK_MIN_MOVE:
			_stuck_timer = 0.0
			_last_position = global_position
		if _stuck_timer >= STUCK_THRESHOLD:
			_stuck_timer = 0.0
			var jump_target = max(height_diff + 0.5, 1.5)
			var jump_vel = sqrt(2.0 * _gravity * jump_target) * 1.1
			velocity.y = clamp(jump_vel, min_jump_velocity, max_jump_velocity)

	if is_on_floor():
		if height_diff > jump_threshold:
			var jump_vel = sqrt(2.0 * _gravity * (height_diff + 0.4)) * 1.05
			velocity.y = clamp(jump_vel, min_jump_velocity, max_jump_velocity)
		else:
			velocity.y = -1.0
	else:
		velocity.y -= _gravity * delta

	move_and_slide()

	if dist < catch_distance:
		_dead = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		AudioManager.play_sfx(AudioManager.sfx_death)
		call_deferred("_trigger_death")

func _trigger_death():
	get_tree().change_scene_to_file("res://death_screen.tscn")

func _can_see_player() -> bool:
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position + Vector3.UP * 0.5,
		player.global_position + Vector3.UP * 0.5
	)
	query.exclude = [self]
	var result = space.intersect_ray(query)
	if result.is_empty():
		return true
	if result.collider == player:
		return true
	return false
