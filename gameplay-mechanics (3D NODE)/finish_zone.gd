extends Area3D

func _on_body_entered(body):
	if body.is_in_group("player"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		call_deferred("_change_to_win")

func _change_to_win():
	get_tree().change_scene_to_file("res://win_screen.tscn")
