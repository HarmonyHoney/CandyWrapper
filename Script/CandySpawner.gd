extends Node2D

var delay := 3.0
var timer := 0.0

var candy_tex = preload("res://Image/Candy.png")

var active := []
var idle := []
var rg = RandomNumberGenerator.new()
onready var global = get_parent()

func _ready():
	rg.randomize()
	scene()

func scene():
	delay = lerp(3.0, 0.333, float(global.level - global.firstLevel) / float(global.lastLevel - global.firstLevel))
	if global.level == global.lastLevel:
		delay = 0.15

func _process(delta):
	timer -= delta
	
	for i in active:
		i.position.y += 60.0 * delta
		if i.position.y > 160:
			idle.append(i)
	
	for i in idle:
		active.erase(i)
	
	if timer < 0:
		timer = delay
		var c
		if idle.size() > 0:
			c = idle.pop_back()
		else:
			c = Sprite.new()
			c.texture = candy_tex
			c.z_index = -1
			add_child(c)
		active.append(c)
		c.flip_h = randf() > 0.5
		c.position.y = -16
		c.position.x = rg.randi_range(0, 144)
