extends KinematicBody2D
class_name Goober

onready var raycast := $RayCast2D
onready var sprite := $Sprite

var game
var spd := 30.0
var vel := Vector2(spd, 0)
var flip_clock := 1.0

func _enter_tree():
	game.goober_array.append(self)

func _exit_tree():
	game.goober_array.erase(self)

func _ready():
	# change starting direction
	randomize()
	if randf() > 0.5:
		flip()

func _physics_process(delta):
	flip_clock += delta
	
	if !raycast.is_colliding():
		flip()
	
	# stay on floor
	move_and_collide(Vector2(0, 1))
	# move horizontally
	var velocity = move_and_slide(Vector2(vel.x, 0))
	if velocity.x == 0:
		flip()
	
	position = game.wrapp(position)

func flip():
	if flip_clock > 0.1:
		vel.x = -vel.x
		sprite.flip_h = !sprite.flip_h
		flip_clock = 0.0



