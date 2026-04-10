# lobby.gd - update this
extends Control

func _on_level1_pressed():
	GameState.selected_level = "res://level_1.tscn"
	get_tree().change_scene_to_file("res://main.tscn")

func _on_level2_pressed():
	GameState.selected_level = "res://level_2.tscn"
	get_tree().change_scene_to_file("res://main.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")
