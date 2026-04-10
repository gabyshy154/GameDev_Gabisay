extends Control

func _ready():
	# Play menu music as soon as the menu loads
	AudioManager.play_music(AudioManager.music_menu)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://lobby.tscn")

func _on_quit_pressed():
	get_tree().quit()
