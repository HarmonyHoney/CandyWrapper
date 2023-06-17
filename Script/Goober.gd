extends CharacterBody2D
class_name Goober

@onready var NodeCast := $RayCast2D
@onready var NodeSprite := $Sprite2D

var spd = 30
var vel = Vector2.ZERO

func _ready():
	# snap to floor
	move_and_collide(Vector2(0, 3))
	vel = Vector2(spd, 0)
	# change starting direction
	randomize()
	if randf() > 0.5:
		vel.x = -vel.x
		NodeSprite.flip_h = true

func _physics_process(delta):
	var cast = NodeCast.is_colliding()
	
	if cast == false:
		vel.x = -vel.x
		NodeSprite.flip_h = !NodeSprite.flip_h
	
	velocity = vel
	move_and_slide()
	if velocity.x == 0:
		vel.x = -vel.x
		NodeSprite.flip_h = !NodeSprite.flip_h
	position = global.wrapp(position)





