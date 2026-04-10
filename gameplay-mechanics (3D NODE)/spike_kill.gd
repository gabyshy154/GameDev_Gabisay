extends Area3D

func _on_body_entered(body):
	print("SPIKE triggered by: ", body.name, " group player=", body.is_in_group("player"))
	if body.is_in_group("player"):
		print("SPIKE KILLED PLAYER at pos: ", body.global_position)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		call_deferred("_change_to_death")

func _change_to_death():
	get_tree().change_scene_to_file("res://death_screen.tscn")
