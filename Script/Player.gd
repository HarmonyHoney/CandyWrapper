extends "res://Script/BaseKine.gd"

# using global singleton btn
#var btn = load("res://Script/btn.gd").new()

var NodeSprite

var HUD
var read = []

var vel = Vector2.ZERO
var spd = 60
var grv = 222
var jumpSpd = 111
var onFloor = false

var termVel = 400



func _ready():
	NodeSprite = get_node("Sprite")
	DOHUD(3)

func DOHUD(arg : int):
	HUD = get_node("/root/Scene/HUD")
	for i in range(arg):
		var nNode = Label.new()
		nNode.name = "Label" + String(i)
		nNode.text = nNode.name
		nNode.margin_top = i * 16
		nNode.add_color_override("font_color", Color.black)
		HUD.add_child(nNode, true)
		read.append(HUD.get_node(nNode.name))

func _physics_process(delta):
	if btn.p("ui_cancel"):
		get_tree().quit()
	
	# gravity
	vel.y += grv * delta
	vel.y = clamp(vel.y, -termVel, termVel)
	
	# horizontal input
	var btnx = btn.d("right") - btn.d("left")
	vel.x = btnx * spd
	
	# jump
	if onFloor and btn.d("jump"):
		vel.y = -jumpSpd
	
	# apply movement
	move_and_slide(vel, flr)
	wrap()
	onFloor = is_on_floor()
	if onFloor:
		vel.y = 0
	
	# animation
	if btnx == 0:
		NodeSprite.TryLoop("Idle")
	else:
		NodeSprite.flip_h = btn.d("left")
		NodeSprite.TryLoop("Run")
	
	
	# HUD
	read[0].text = "onFloor: " + String(onFloor)
	read[1].text = "vel.x: " + String(vel.x)
	read[2].text = "vel.y: " + String(vel.y)
	
	

