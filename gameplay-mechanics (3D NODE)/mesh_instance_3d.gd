extends MeshInstance3D

var speed = 2.0
var direction = Vector3(1, 0, 1)  # diagonal movement

func _process(delta):
	position += direction * speed * delta

	# Bounce within a boundary
	if position.x > 5 or position.x < -5:
		direction.x *= -1
	if position.z > 5 or position.z < -5:
		direction.z *= -1
