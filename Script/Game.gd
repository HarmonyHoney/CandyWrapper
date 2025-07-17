extends Node2D

var tmpath := "res://TileMap/"
enum {TILE_WALL = 0, TILE_PLAYER = 1, TILE_GOOBER = 2}
var NodeTileMap

var OST = load("res://Audio/OST.mp3")
var audio

var ScenePlayer = load("res://Scene/Player.tscn")
var SceneGoober = load("res://Scene/Goober.tscn")
var SceneExplo = load("res://Scene/Explosion.tscn")

onready var NodeGoobers := $Goobers
onready var actors := $Actors
onready var NodeAudioWin := $Audio/Win
onready var NodeAudioLose := $Audio/Lose
onready var NodeSprite := $Sprite

var clock := 0.0
var delay := 1.5
var delay_init = 1.5
var check := false
var change := false
var rg := RandomNumberGenerator.new()

var level := 0
var level_start := 0
var level_end := 21

onready var falling_candy := $FallingCandy

func _ready():
	rg.randomize()
	
	new_map()
	
	yield(get_tree().create_timer(0.3), "timeout")
	
	audio = AudioStreamPlayer.new()
	add_child(audio)
	audio.stream = OST
	audio.play()
	audio.connect("finished", audio, "play")

func new_map():
	for i in NodeGoobers.get_children():
		i.queue_free()
	for i in actors.get_children():
		i.queue_free()
	
	change = false
	check = false
	delay = delay_init
	clock = 0
	
	NodeSprite.visible = false
	
	if level == level_start or level == level_end:
		NodeSprite.frame = 0 if level == level_start else 3
		NodeSprite.visible = true
		var p = ScenePlayer.instance()
		p.position = Vector2(72, 85)
		p.scale.x = -1 if randf() < 0.5 else 1
		p.set_script(null)
		actors.add_child(p)
	
	MapLoad()
	MapStart()
	falling_candy.scene()

func _process(delta):
	clock += delta
	# title screen is the first level, and "game complete" screen is the last level:
	if btnp("jump") and (level == level_start or (level == level_end and clock > 0.5)):
		level = posmod(level + 1, level_end + 1)
		new_map()
	
	MapChange(delta)

func MapLoad():
	var nxtlvl = min(level, level_end)
	var tm = load(tmpath + str(nxtlvl) + ".tscn").instance()
	tm.name = "TileMap"
	tm.z_as_relative = false
	tm.z_index = 0
	actors.add_child(tm)
	NodeTileMap = tm

func MapStart():
	print("--- MapStart: Begin ---")
	print("level: ", level)
	for pos in NodeTileMap.get_used_cells():
		var id = NodeTileMap.get_cellv(pos)
		if id == TILE_WALL:
			print(pos, ": Wall")
			var atlas = Vector2(rg.randi_range(0, 2), rg.randi_range(0, 2))
			NodeTileMap.set_cellv(pos, TILE_WALL, false, false, false, atlas)
		elif id == TILE_PLAYER or id == TILE_GOOBER:
			var p = id == TILE_PLAYER
			print(pos, ": Player" if p else ": Goober")
			var inst = (ScenePlayer if p else SceneGoober).instance()
			inst.position = (NodeTileMap.cell_size * pos) + Vector2(4, 4.99)
			inst.game = self
			(actors if p else NodeGoobers).add_child(inst)
			# remove tile from map
			NodeTileMap.set_cellv(pos, -1)
	print("--- MapStart: End ---")

func MapChange(delta):
	# if its time to change scene
	if change:
		delay -= delta
		if delay < 0:
			new_map()
		return # skip the rest if change == true
	
	# should i check?
	if check:
		check = false
		var count = NodeGoobers.get_child_count()
		print("Goobers: ", count)
		if count == 0:
			Win()

func Lose():
	change = true
	NodeAudioLose.pitch_scale = rand_range(0.9, 1.1)
	NodeAudioLose.play()
	NodeSprite.visible = true
	NodeSprite.frame = 2
	level = max(0, level - 1)

func Win():
	change = true
	NodeAudioWin.pitch_scale = rand_range(0.9, 1.1)
	NodeAudioWin.play()
	NodeSprite.visible = true
	NodeSprite.frame = 1
	level = min(level_end, level + 1)
	print("Level Complete!, change to level: ", level)

func Explode(arg : Vector2):
	var xpl = SceneExplo.instance()
	xpl.position = arg
	xpl.get_node("AudioStreamPlayer").pitch_scale = rand_range(0.9, 1.1)
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

