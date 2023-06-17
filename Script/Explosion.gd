extends Node2D

@onready var NodeSprite := $Sprite2D

func End():
	queue_free()
