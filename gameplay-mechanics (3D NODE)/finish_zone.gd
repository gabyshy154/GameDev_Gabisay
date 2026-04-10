extends Area3D

func _on_body_entered(body):
	print("FINISH ZONE triggered by: ", body.name, " group player=", body.is_in_group("player"))
	if body.is_in_group("player"):
		print("FINISH ZONE sending to win screen")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		call_deferred("_change_to_win")

func _change_to_win():
	get_tree().change_scene_to_file("res://win_screen.tscn")
