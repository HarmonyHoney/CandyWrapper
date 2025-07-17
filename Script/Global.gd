extends Node2D

export var game_scene : PackedScene
var game_node

var level := 0
const firstLevel := 0
const lastLevel := 21
var Game

var OST = load("res://Audio/OST.mp3")
var audio

onready var falling_candy := $FallingCandy

func _ready():
	yield(get_tree().create_timer(0.1), "timeout")
	
	audio = AudioStreamPlayer.new()
	add_child(audio)
	audio.stream = OST
	audio.play()
	audio.connect("finished", audio, "play")
	
	scene_change()

#func _input(event):
#	if event.is_action_pressed("ui_fullscreen"):
#		var win_full = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
#		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE if win_full else DisplayServer.MOUSE_MODE_HIDDEN)
#		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if win_full else DisplayServer.WINDOW_MODE_FULLSCREEN)

func wrapp(pos := Vector2.ZERO):
	return Vector2(wrapf(pos.x, 0.0, 144.0), wrapf(pos.y, 0.0, 144.0))

func scene_change():
	if is_instance_valid(game_node):
		game_node.queue_free()
	
	game_node = game_scene.instance()
	game_node.global = self
	add_child(game_node)
	falling_candy.scene()

func NumBool(arg : bool):
	return 1 if arg else 0

# DOWN
func d(arg : String):
	return NumBool(Input.is_action_pressed(arg))

# PRESSED
func p(arg : String):
	return NumBool(Input.is_action_just_pressed(arg))

# RELEASED
func r(arg : String):
	return NumBool(Input.is_action_just_released(arg))
