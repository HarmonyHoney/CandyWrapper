extends Node2D

var NodeSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	NodeSprite = get_node("Sprite")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if NodeSprite.frame == 3:
		queue_free()
