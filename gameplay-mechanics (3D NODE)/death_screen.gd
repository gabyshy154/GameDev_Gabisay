extends Control

func _ready():
	print("=== DEATH SCREEN LOADED ===")

func _on_retry_pressed():
	get_tree().change_scene_to_file("res://main.tscn")

func _on_lobby_pressed():
	get_tree().change_scene_to_file("res://lobby.tscn")
