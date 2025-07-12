extends KinematicBody2D
class_name BaseKine

const flr = Vector2(0, -1)

func wrap():
	if position.x < 0:
		position.x += 144
	elif position.x > 144:
		position.x -= 144
	if position.y < 0:
		position.y += 144
	elif position.y > 144:
		position.y -= 144
