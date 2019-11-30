extends Node

var OST = load("res://Audio/OST.ogg")
var Player

func _ready():
	var plr = AudioStreamPlayer.new()
	plr.name = "Player"
	add_child(plr)
	Player = get_node("Player")
	Player.stream = OST
	Player.play()
