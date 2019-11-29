extends Node

func NumBool(arg : bool):
	return 1 if arg else 0

func btn(arg : String):
	return NumBool(Input.is_action_pressed(arg))

func btnp(arg : String):
	return NumBool(Input.is_action_just_pressed(arg))

func btnr(arg : String):
	return NumBool(Input.is_action_just_released(arg))