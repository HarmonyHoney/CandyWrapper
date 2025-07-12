extends BaseKine

onready var game = get_parent()
onready var NodeSprite = $"Sprite"
onready var NodeArea2D = $"Area2D"
onready var NodeAudio = $"Audio"
onready var NodeAnim = $"AnimationPlayer"

export var SceneExplo : PackedScene

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
	# create hud labels
	#DOHUD(5)

func DOHUD(arg : int):
	var fnt = load("res://Font/m3x6.tres")
	HUD = game.get_node("HUD")
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
	var btnx = game.d("right") - game.d("left")
	vel.x = btnx * spd
	
	# jump
	if onFloor:
		if game.p("jump"):
			jump = true
			vel.y = -jumpSpd
			NodeAudio.play()
	elif jump:
		if !game.d("jump") and vel.y < jumpSpd / -3:
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
		NodeSprite.flip_h = game.d("left")
	
	# animation
	if onFloor:
		if btnx == 0:
			TryLoop("Idle")
		else:
			TryLoop("Run")
	else:
		TryLoop("Jump")
	
	
	# HUD
	#read[0].text = "onFloor: " + String(onFloor)
	#read[1].text = "pos.x: " + String(position.x)
	#read[2].text = "pos.y: " + String(position.y)
	#read[3].text = "vel.x: " + String(vel.x)
	#read[4].text = "vel.y: " + String(vel.y)



func Explode(arg : Vector2):
	var xpl = SceneExplo.instance()
	xpl.position = arg
	game.add_child(xpl)

func Die():
	queue_free()
	Explode(position)
	game.Lose()

func Overlap():
	var hit = false
	var overlap = NodeArea2D.get_overlapping_areas()
	for o in overlap:
		print ("Overlapping: ", o.get_parent().name)
		var par = o.get_parent()
		#print()
		if par is Goober:
			if onFloor:
				Die()
			else:
				if game.d("jump"):
					jump = true
					vel.y = -jumpSpd
				else:
					jump = false
					vel.y = -jumpSpd * 0.6
				par.queue_free()
				Explode(par.position)
				game.check = true
				print("Goober destroyed")
				hit = true
	return hit

func TryLoop(arg : String):
	if arg == NodeAnim.current_animation:
		return false
	else:
		NodeAnim.play(arg)
		return true
