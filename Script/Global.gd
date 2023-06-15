extends Node2D

var level = 0
var lastLevel = 21

var Main
var Game

var OST = load("res://Audio/OST.ogg")
var audio

func _ready():
	await get_tree().create_timer(0.1).timeout
	
	audio = AudioStreamPlayer.new()
	audio.name = "Audio"
	add_child(audio)
	audio.stream = OST
	audio.play()
