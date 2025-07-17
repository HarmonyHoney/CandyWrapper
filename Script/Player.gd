extends KinematicBody2D

var game
onready var sprite := $Sprite
onready var area := $Area2D
onready var audio := $Audio
onready var anim := $AnimationPlayer

var vel := Vector2.ZERO
var spd := 60.0
var grv := 255.0
var jump_vel := 133.0
var term_vel := 400.0

var is_floor := false
var jump := false

func _physics_process(delta):
	# gravity
	vel.y += grv * delta
	vel.y = clamp(vel.y, -term_vel, term_vel)
	
	# horizontal input
	var btnx = game.btnd("right") - game.btnd("left")
	vel.x = btnx * spd
	
	# jump
	if is_floor:
		if game.btnp("jump"):
			jump = true
			vel.y = -jump_vel
			audio.pitch_scale = rand_range(0.9, 1.1)
			audio.play()
	elif jump:
		if !game.btnd("jump") and vel.y < jump_vel / -3:
			jump = false
			vel.y = jump_vel / -3
	
	# apply movement
	var velocity = move_and_slide(vel)
	position = game.wrapp(position)
	# check for Goobers
	var hit = Overlap()
	if !hit:
		if velocity.y == 0:
			vel.y = 0
		# check for floor 0.1 pixel down
		is_floor = test_move(transform, Vector2(0, 0.1))
	
	# sprite flip
	if btnx != 0:
		sprite.flip_h = btnx < 0
	
	# animation
	if is_floor:
		if btnx == 0:
			TryLoop("Idle")
		else:
			TryLoop("Run")
	else:
		TryLoop("Jump")

func Die():
	queue_free()
	game.explode(position)
	game.lose()

func Overlap():
	var hit = false
	
	for o in area.get_overlapping_areas():
		var par = o.get_parent()
		print ("Overlapping: ", par.name)
		
		if par is Goober:
			var above = position.y - 1 < par.position.y
			
			if is_floor or (vel.y < 0.0 and !above):
				Die()
			else:
				hit = true
				jump = game.btnd("jump")
				vel.y = -jump_vel * (1.0 if jump else 0.6)
				
				par.queue_free()
				game.explode(par.position)
				game.check = true
				print("Goober destroyed")
	return hit

func TryLoop(arg : String):
	if arg == anim.current_animation:
		return false
	else:
		anim.play(arg)
		return true
