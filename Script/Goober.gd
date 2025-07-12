extends BaseKine
class_name Goober

onready var NodeCast = $"RayCast2D"
onready var NodeSprite = $"Sprite"

var spd = 30
var vel = Vector2.ZERO


func _ready():
	move_and_collide(Vector2(0, 32)) # move down 8 pixels to floor
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





