extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if btnp("ui_cancel"):
		get_tree().quit()


func NumBool(arg : bool):
	return 1 if arg else 0

func btn(arg : String):
	return NumBool(Input.is_action_pressed(arg))

func btnp(arg : String):
	return NumBool(Input.is_action_just_pressed(arg))

func btnr(arg : String):
	return NumBool(Input.is_action_just_released(arg))