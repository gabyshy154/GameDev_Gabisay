extends Node

# Use get_node_or_null so the game doesn't crash if they are missing
@onready var music_player = get_node_or_null("MusicPlayer")
@onready var sfx_player = get_node_or_null("SFXPlayer")

var music_menu = preload("res://audio/music_menu.mp3")
var music_game = preload("res://audio/music_game.mp3")
var sfx_jump = preload("res://audio/sfx_jump.mp3")
var sfx_land = preload("res://audio/sfx_land.mp3")
var sfx_death = preload("res://audio/sfx_death.mp3")

func _ready():
	# Only set the bus if the node actually exists
	if music_player:
		music_player.bus = "Music"
	else:
		print("Warning: MusicPlayer node not found in AudioManager scene.")
		
	if sfx_player:
		sfx_player.bus = "SFX"
	else:
		print("Warning: SFXPlayer node not found in AudioManager scene.")

func play_music(stream: AudioStream):
	if not music_player: return
	
	if music_player.stream == stream and music_player.playing:
		return
	music_player.stream = stream
	music_player.play()

func stop_music():
	if music_player:
		music_player.stop()

func play_sfx(stream: AudioStream):
	# Using the multi-sound method to prevent cutting off
	var new_player = AudioStreamPlayer.new()
	add_child(new_player)
	new_player.stream = stream
	new_player.bus = "SFX"
	new_player.play()
	new_player.finished.connect(new_player.queue_free)
