extends Sprite2D

var speed = 200  # pixels per second
var direction = Vector2(1, 1)  # moving diagonally

func _process(delta):
	position += direction * speed * delta
	
	# Bounce off screen edges
	var screen = get_viewport_rect().size
	if position.x > screen.x or position.x < 0:
		direction.x *= -1
	if position.y > screen.y or position.y < 0:
		direction.y *= -1
