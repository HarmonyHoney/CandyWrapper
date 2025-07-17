extends Node2D

var delay := 3.0
var timer := 0.0

var candy_tex = preload("res://Image/Candy.png")

var active := []
var idle := []
var rg = RandomNumberGenerator.new()
onready var game = get_parent()
export var delay_range = Vector2(3.0, 0.333)
export var delay_end = 0.15

func _ready():
	rg.randomize()
	scene()

func scene():
	delay = lerp(delay_range.x, delay_range.y, float(game.level - game.level_start) / float(game.level_end - game.level_start))
	if game.level == game.level_end:
		delay = delay_end

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
