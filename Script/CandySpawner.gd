extends Node2D

var SceneCandy
var delay = 5
var timer = 0

var rand = RandomNumberGenerator.new()

func _ready():
	SceneCandy = load("res://Scene/Candy.tscn")
	rand.randomize()

func _process(delta):
	timer -= delta
	
	if timer < 0:
		timer = delay
		var cnd = SceneCandy.instance()
		cnd.position.y = -16
		cnd.position.x = rand.randi_range(0, 144)
		add_child(cnd)
