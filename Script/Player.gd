extends CharacterBody2D

@onready var NodeScene = global.Game
@onready var NodeSprite := $Sprite2D
@onready var NodeArea2D := $Area2D
@onready var NodeAudio := $Audio
@onready var NodeAnim := $AnimationPlayer

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
	# snap down 8 pixels, if floor is present
	var vecdn = Vector2(0, 8)
	if test_move(transform, vecdn):
		move_and_collide(vecdn)
	startPos = position

func DOHUD(arg : int):
	var fnt = load("res://Font/m3x6.tres")
	HUD = NodeScene.get_node("HUD")
	for i in range(arg):
		var nNode = Label.new()
		nNode.name = "Label" + str(i)
		nNode.text = nNode.name
		nNode.offset_top = (i * 7) - 4
		nNode.offset_left = 1
		nNode.uppercase = true
		nNode.add_theme_color_override("font_color", Color.BLACK)
		nNode.add_theme_font_override("font", fnt)
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
			NodeAudio.play()
	elif jump:
		if !btn.d("jump") and vel.y < jumpSpd / -3:
			jump = false
			vel.y = jumpSpd / -3
	
	# apply movement
	velocity = vel
	move_and_slide()
	position = global.wrapp(position)
	# check for Goobers
	var hit = Overlap()
	if !hit:
		if velocity.y == 0:
			vel.y = 0
		# check for floor 0.1 pixel down
		onFloor = test_move(transform, Vector2(0, 0.1))
	
	# sprite flip
	if btnx !=0:
		NodeSprite.flip_h = btn.d("left")
	
	# animation
	if onFloor:
		if btnx == 0:
			TryLoop("Idle")
		else:
			TryLoop("Run")
	else:
		TryLoop("Jump")
	
	
	# HUD
	#read[0].text = "onFloor: " + str(onFloor)
	#read[1].text = "pos.x: " + str(position.x)
	#read[2].text = "pos.y: " + str(position.y)
	#read[3].text = "vel.x: " + str(vel.x)
	#read[4].text = "vel.y: " + str(vel.y)



func Explode(arg : Vector2):
	var xpl = SceneExplo.instantiate()
	xpl.position = arg
	NodeScene.add_child(xpl)

func Die():
	queue_free()
	Explode(position)
	global.Game.Lose()

func Overlap():
	var hit = false
	
	for o in NodeArea2D.get_overlapping_areas():
		var par = o.get_parent()
		print ("Overlapping: ", par.name)
		
		if par is Goober:
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

func TryLoop(arg : String):
	if arg == NodeAnim.current_animation:
		return false
	else:
		NodeAnim.play(arg)
		return true
