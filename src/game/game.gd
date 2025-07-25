extends Node2D

@export_dir var tmpath := "res://TileMap/"
@export var OST : AudioStream
@export var scene_player : PackedScene
@export var scene_goober : PackedScene
@export var scene_explode : PackedScene

@onready var actors := $Actors
@onready var audio_win := $Audio/Win
@onready var audio_lose := $Audio/Lose
@onready var sprite := $Sprite
@onready var falling_candy := $FallingCandy
@onready var tile_back := $TileBack

enum {TILE_WALL = 0, TILE_PLAYER = 1, TILE_GOOBER = 2}
var tile_map
var audio
var level := 0
var level_start := 0
var level_end := 21
var map_clock := Vector2(0, 0.5)
var delay_clock := Vector2(0, 1.5)
var is_check := false
var is_change := false
var goober_array = []

func _ready():
	randomize()
	
	map_next()
	
	await get_tree().create_timer(0.5).timeout
	
	audio = AudioStreamPlayer.new()
	add_child(audio)
	audio.stream = OST
	audio.play()
	audio.finished.connect(audio.play)

func _input(event):
	if event.is_action_pressed("ui_fullscreen"):
		var win_full = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE if win_full else DisplayServer.MOUSE_MODE_HIDDEN)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if win_full else DisplayServer.WINDOW_MODE_FULLSCREEN)


func _process(delta):
	map_clock.x += delta
	# title screen is the first level, and "game complete" screen is the last level:
	if btnp("jump") and (level == level_start or (level == level_end and map_clock.x > map_clock.y)):
		level = posmod(level + 1, level_end + 1)
		map_next()
	
	map_change_check(delta)

func map_next():
	for i in actors.get_children():
		i.queue_free()
	
	is_change = false
	is_check = false
	delay_clock.x = 0
	map_clock.x = 0
	goober_array = []
	
	sprite.visible = false
	
	if level == level_start or level == level_end:
		sprite.frame = 0 if level == level_start else 3
		sprite.visible = true
		var p = scene_player.instantiate()
		p.position = Vector2(72, 85)
		p.scale.x = -1 if randf() < 0.5 else 1
		p.set_script(null)
		actors.add_child(p)
	
	map_load()
	falling_candy.scene()

func map_load():
	print("--- map_load(): Begin --- level: ", level)
	var nxtlvl = clamp(level, level_start, level_end)
	var tm = load(tmpath + "/" + str(int(nxtlvl)) + ".tscn").instantiate()
	tm.z_as_relative = false
	tm.z_index = 0
	actors.add_child(tm)
	tile_map = tm
	tile_back.clear()
	
	for pos in tile_map.get_used_cells(0):
		var id = tile_map.get_cell_source_id(0, pos)
		if id == TILE_WALL:
			print(pos, ": Wall")
			var atlas = Vector2(randi_range(0, 2), randi_range(0, 2))
			tile_map.set_cell(0, pos, TILE_WALL, atlas)
			tile_back.set_cell(pos, 1,Vector2i(0, 0))
		elif id == TILE_PLAYER or id == TILE_GOOBER:
			var p = id == TILE_PLAYER
			print(pos, ": Player" if p else ": Goober")
			var inst = (scene_player if p else scene_goober).instantiate()
			inst.position = (pos * Vector2i(8, 8)) + Vector2i(4, 5.99)
			inst.game = self
			actors.add_child(inst)
			# remove tile from map
			tile_map.set_cell(0, pos, -1)
	print("--- map_load(): End ---")

func map_change_check(delta):
	# should i check?
	if is_check:
		is_check = false
		var count = goober_array.size()
		print("Goobers left: ", count)
		if count == 0:
			win()
	# else if its time to change scene
	elif is_change:
		delay_clock.x += delta
		if delay_clock.x > delay_clock.y:
			map_next()

func win():
	is_change = true
	audio_win.pitch_scale = randf_range(0.9, 1.1)
	audio_win.play()
	sprite.visible = true
	sprite.frame = 1
	level = min(level_end, level + 1)
	print("Level Complete!, change to level: ", level)

func lose():
	is_change = true
	audio_lose.pitch_scale = randf_range(0.9, 1.1)
	audio_lose.play()
	sprite.visible = true
	sprite.frame = 2
	level = max(0, level - 1)

func explode(arg : Vector2):
	var xpl = scene_explode.instantiate()
	xpl.position = arg
	xpl.get_node("Audio").pitch_scale = randf_range(0.9, 1.1)
	actors.add_child(xpl)

# BUTTON DOWN
func btnd(arg : String):
	return int(bool(Input.is_action_pressed(arg)))

# BUTTON PRESSED
func btnp(arg : String):
	return int(bool(Input.is_action_just_pressed(arg)))

# BUTTON RELEASED
func btnr(arg : String):
	return int(bool(Input.is_action_just_released(arg)))

# wrap screen
func wrapp(pos := Vector2.ZERO):
	return Vector2(wrapf(pos.x, 0.0, 144.0), wrapf(pos.y, 0.0, 144.0))
