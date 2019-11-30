extends "res://Script/BaseKine.gd"
class_name Goober

var NodeCast
var NodeSprite

var spd = 30
var vel = Vector2.ZERO


func _ready():
	NodeSprite = get_node("Sprite")
	NodeCast = get_node("RayCast2D")
	move_and_collide(Vector2(0, 16)) # move down 8 pixels to floor
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
	
	var mov = move_and_slide(vel)
	if mov.x == 0:
		vel.x = -vel.x
		NodeSprite.flip_h = !NodeSprite.flip_h
	wrap()





