extends "res://Script/BaseKine.gd"

var NodeScene
var NodeSprite
var NodeArea2D

var SceneExplo = load("res://Scene/Explosion.tscn")

var HUD
var read = []

var vel = Vector2.ZERO
var spd = 60
var grv = 255
var jumpSpd = 133
var termVel = 400

var onFloor = false
var jump = false

var startPos

func _ready():
	NodeScene = global.NodeScene
	
	# snap down 8 pixels, if floor is present
	var vecdn = Vector2(0, 8)
	if test_move(transform, vecdn):
		move_and_collide(vecdn)
	startPos = position
	# create hud labels
	#DOHUD(5)
	
	# reference nodes
	NodeSprite = get_node("Sprite")
	NodeArea2D = get_node("Area2D")

func DOHUD(arg : int):
	var fnt = load("res://Font/m3x6.tres")
	HUD = NodeScene.get_node("HUD")
	for i in range(arg):
		var nNode = Label.new()
		nNode.name = "Label" + String(i)
		nNode.text = nNode.name
		nNode.margin_top = (i * 7) - 4
		nNode.margin_left = 1
		nNode.uppercase = true
		nNode.add_color_override("font_color", Color.black)
		nNode.add_font_override("font", fnt)
		HUD.add_child(nNode, true)
		read.append(HUD.get_node(nNode.name))

func _physics_process(delta):
	# gravity
	vel.y += grv * delta
	vel.y = clamp(vel.y, -termVel, termVel)
	
	# horizontal input
	var btnx = btn.d("right") - btn.d("left")
	vel.x = btnx * spd
	
	# jump
	if onFloor:
		if btn.p("jump"):
			jump = true
			vel.y = -jumpSpd
	elif jump:
		if !btn.d("jump") and vel.y < jumpSpd / -3:
			jump = false
			vel.y = jumpSpd / -3
	
	# apply movement
	var mov = move_and_slide(vel, flr)
	wrap()
	# check for Goobers
	var hit = Overlap()
	if !hit:
		if mov.y == 0:
			vel.y = 0
		# check for floor 0.1 pixel down
		onFloor = test_move(transform, Vector2(0, 0.1))
	
	# sprite flip
	if btnx !=0:
		NodeSprite.flip_h = btn.d("left")
	
	# animation
	if onFloor:
		if btnx == 0:
			NodeSprite.TryLoop("Idle")
		else:
			NodeSprite.TryLoop("Run")
	else:
		NodeSprite.TryLoop("Jump")
	
	
	# HUD
	#read[0].text = "onFloor: " + String(onFloor)
	#read[1].text = "pos.x: " + String(position.x)
	#read[2].text = "pos.y: " + String(position.y)
	#read[3].text = "vel.x: " + String(vel.x)
	#read[4].text = "vel.y: " + String(vel.y)



func Explode(arg : Vector2):
	var xpl = SceneExplo.instance()
	xpl.position = arg
	NodeScene.add_child(xpl)

func Die():
	#queue_free()
	Explode(position)
	position = startPos

func Overlap():
	var hit = false
	var overlap = NodeArea2D.get_overlapping_areas()
	for o in overlap:
		print ("Overlapping: ", o.get_parent().name)
		var par = o.get_parent()
		#print()
		if par is global.Goober:
			if onFloor:
				Die()
			else:
				if btn.d("jump"):
					jump = true
					vel.y = -jumpSpd
				else:
					jump = false
					vel.y = -jumpSpd * 0.6
				par.queue_free()
				Explode(par.position)
				NodeScene.check = true
				print("Goober destroyed")
				hit = true
	return hit

