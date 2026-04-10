extends Control

func _ready():
	print("=== WIN SCREEN LOADED ===")

func _on_next_pressed():
	if GameState.selected_level == "res://level_1.tscn":
		GameState.selected_level = "res://level_2.tscn"
	else:
		get_tree().change_scene_to_file("res://lobby.tscn")
		return
	call_deferred("_go_to_main")

func _go_to_main():
	get_tree().change_scene_to_file("res://main.tscn")

func _on_lobby_pressed():
	get_tree().change_scene_to_file("res://lobby.tscn")
