extends Node2D

export var game_scene : PackedScene
onready var title := $"Title"

var level = 0
var lastLevel = 21

var game

func _ready():
	start_game()

func start_game():
	title.visible = false
	if is_instance_valid(game):
		game.queue_free()
	game = game_scene.instance()
	game.arcade = self
	add_child(game)
	game.owner = self
