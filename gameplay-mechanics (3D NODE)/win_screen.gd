extends Control

func _ready():
	print("=== WIN SCREEN LOADED ===")
	# Play the "landing/finish" sound as a victory chime
	AudioManager.play_sfx(AudioManager.sfx_land)
	# Switch music back to menu style
	AudioManager.play_music(AudioManager.music_menu)

func _on_next_pressed():
	if GameState.selected_level == "res://level_1.tscn":
		GameState.selected_level = "res://level_2.tscn"
	else:
		get_tree().change_scene_to_file("res://lobby.tscn")
		return
	get_tree().change_scene_to_file("res://main.tscn")

func _on_lobby_pressed():
	get_tree().change_scene_to_file("res://lobby.tscn")
