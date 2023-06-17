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
	if !NodeCast.is_colliding():
		flip()
	
	velocity = vel
	move_and_slide()
	if velocity.x == 0:
		flip()
	position = global.wrapp(position)

func flip():
	vel.x = -vel.x
	NodeSprite.flip_h = !NodeSprite.flip_h



