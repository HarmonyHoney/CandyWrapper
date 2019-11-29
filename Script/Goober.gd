extends "res://Script/BaseKine.gd"

var NodeCast
var NodeSprite

var spd = 30
var vel = Vector2.ZERO


func _ready():
	NodeSprite = get_node("Sprite")
	NodeCast = get_node("RayCast2D")
	
	vel = Vector2(spd, 0)
	move_and_collide(Vector2(0, 8)) # move down 8 pixels

func _physics_process(delta):
	var cast = NodeCast.is_colliding()
	
	if cast == false:
		vel.x = -vel.x
		NodeSprite.flip_h = !NodeSprite.flip_h
	
	move_and_slide(vel)
	
