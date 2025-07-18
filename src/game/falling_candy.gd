extends Node2D

@export var candy_tex : Texture
@export var delay_range = Vector2(3.0, 0.333)
@export var delay_end = 0.15

@onready var game = get_parent()

var active := []
var idle := []
var clock := 0.0
var delay := 3.0

func _ready():
	scene()

func scene():
	delay = lerp(delay_range.x, delay_range.y, float(game.level - game.level_start) / float(game.level_end - game.level_start))
	if game.level == game.level_end:
		delay = delay_end

func _process(delta):
	
	for i in active:
		i.position.y += 60.0 * delta
		if i.position.y > 160:
			idle.append(i)
	
	for i in idle:
		active.erase(i)
	
	clock += delta
	
	if clock > delay:
		clock = 0
		var c
		if idle.size() > 0:
			c = idle.pop_back()
		else:
			c = Sprite2D.new()
			c.texture = candy_tex
			c.z_index = -1
			add_child(c)
		active.append(c)
		c.flip_h = randf() > 0.5
		c.position.y = -16
		c.position.x = randi_range(0, 144)
