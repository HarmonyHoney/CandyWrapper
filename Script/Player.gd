extends "res://Script/BaseKine.gd"

# using global singleton btn
#var btn = load("res://Script/btn.gd").new()

var NodeSprite

var vel = Vector2.ZERO
var spd = 60

var flr = Vector2(0, -1)

func _ready():
	NodeSprite = get_node("Sprite")

func _physics_process(delta):
	if btn.p("ui_cancel"):
		get_tree().quit()
	
	var btnx = btn.d("right") - btn.d("left")
	vel.x = btnx * spd
	
	var btny = btn.d("down") - btn.d("up")
	vel.y = btny * spd
	
	move_and_slide(vel, flr)
	
	wrap()
	
	# animation
	if btnx == 0:
		NodeSprite.TryLoop("Idle")
	else:
		NodeSprite.flip_h = btn.d("left")
		NodeSprite.TryLoop("Run")


