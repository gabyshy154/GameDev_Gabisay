extends Node3D

@onready var player = $Player3D

var current_level: Node = null

func _ready():
	call_deferred("_load_first_level")

func _load_first_level():
	load_level(GameState.selected_level)

func load_level(path: String):
	# Free old level
	if current_level:
		current_level.queue_free()
		current_level = null

	# Load and add new level
	var level_scene = load(path)
	if level_scene == null:
		print("ERROR: Could not load: ", path)
		return

	current_level = level_scene.instantiate()
	add_child(current_level)

	# Defer spawn setup so tree is ready
	call_deferred("_setup_spawns")

func _setup_spawns():
	# Extra safety — wait one frame
	if not is_inside_tree():
		await get_tree().process_frame

	var player_spawn = get_tree().get_first_node_in_group("spawn_point")
	if player_spawn:
		player.global_position = player_spawn.global_position
		player.spawn_position = player_spawn.global_position
	else:
		print("WARNING: No spawn_point found in level")
