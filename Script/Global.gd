extends Node2D

var level = 0
var lastLevel = 21
var Game

var OST = load("res://Audio/OST.ogg")
var audio

func _ready():
	await get_tree().create_timer(0.1).timeout
	
	audio = AudioStreamPlayer.new()
	add_child(audio)
	audio.stream = OST
	audio.play()
	audio.finished.connect(audio.play)

func _input(event):
	if event.is_action_pressed("ui_fullscreen"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN)

func wrapp(pos := Vector2.ZERO):
	return Vector2(wrapf(pos.x, 0.0, 144.0), wrapf(pos.y, 0.0, 144.0))
