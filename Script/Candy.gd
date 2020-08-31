extends Node2D

var spd = 60

# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = -1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y += spd * delta
	
	if position.y > 160:
		queue_free()
