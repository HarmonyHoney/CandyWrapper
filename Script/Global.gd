extends Node2D

var level = 0
var lastLevel = 21
var Game

func wrapp(pos := Vector2.ZERO):
	return pos# Vector2(wrapf(pos.x, 0.0, 144.0), wrapf(pos.y, 0.0, 144.0))
