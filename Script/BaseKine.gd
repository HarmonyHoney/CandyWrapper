extends CharacterBody2D
class_name BaseKine

const flr = Vector2(0, -1)

func wrapp():
	pass#position = Vector2(wrapf(position.x, 0.0, 144.0), wrapf(position.y, 0.0, 144.0))
