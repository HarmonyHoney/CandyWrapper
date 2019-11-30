extends Node2D

var SceneCandy
var delay = 3
var timer = 0

var rand = RandomNumberGenerator.new()

func _ready():
	SceneCandy = load("res://Scene/Candy.tscn")
	rand.randomize()
	#delay = (global.lastLevel / global.level)
	delay = lerp(3, 0.6, global.level / global.lastLevel)
	

func _process(delta):
	timer -= delta
	
	if timer < 0:
		timer = delay
		var cnd = SceneCandy.instance()
		cnd.position.y = -16
		cnd.position.x = rand.randi_range(0, 144)
		add_child(cnd)
