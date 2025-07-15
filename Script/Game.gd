extends Node2D

var tmpath := "res://TileMap/"
enum {TILE_WALL = 0, TILE_PLAYER = 1, TILE_GOOBER = 2}
var NodeTileMap

var ScenePlayer = load("res://Scene/Player.tscn")
var SceneGoober = load("res://Scene/Goober.tscn")
var SceneExplo = load("res://Scene/Explosion.tscn")

onready var NodeGoobers := $Goobers
onready var NodeAudioWin := $Audio/Win
onready var NodeAudioLose := $Audio/Lose
onready var NodeSprite := $Sprite

var clock := 0.0
var delay := 1.5
var check := false
var change := false
var rg := RandomNumberGenerator.new()

func _ready():
	rg.randomize()
	global.Game = self
	
	if global.level == global.firstLevel or global.level == global.lastLevel:
		NodeSprite.frame = 0 if global.level == global.firstLevel else 3
		NodeSprite.visible = true
		var p = ScenePlayer.instance()
		p.position = Vector2(72, 85)
		p.scale.x = -1 if randf() < 0.5 else 1
		p.set_script(null)
		add_child(p)
	
	MapLoad()
	MapStart()

func _process(delta):
	clock += delta
	# title screen is the first level, and "game complete" screen is the last level:
	if btn.p("jump") and (global.level == global.firstLevel or (global.level == global.lastLevel  and clock > 0.5)):
		global.level = posmod(global.level + 1, global.lastLevel + 1)
		DoChange()
	
	MapChange(delta)

func MapLoad():
	var nxtlvl = min(global.level, global.lastLevel)
	var tm = load(tmpath + str(nxtlvl) + ".tscn").instance()
	tm.name = "TileMap"
	tm.z_as_relative = false
	tm.z_index = 0
	add_child(tm)
	NodeTileMap = tm

func MapStart():
	print("--- MapStart: Begin ---")
	print("global.level: ", global.level)
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
			inst.position = (NodeTileMap.cell_size * pos) + Vector2(4, 0 if p else 5)
			(self if p else NodeGoobers).add_child(inst)
			# remove tile from map
			NodeTileMap.set_cellv(pos, -1)
	print("--- MapStart: End ---")

func MapChange(delta):
	# if its time to change scene
	if change:
		delay -= delta
		if delay < 0:
			DoChange()
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
	global.level = max(0, global.level - 1)

func Win():
	change = true
	NodeAudioWin.pitch_scale = rand_range(0.9, 1.1)
	NodeAudioWin.play()
	NodeSprite.visible = true
	global.level = min(global.lastLevel, global.level + 1)
	print("Level Complete!, change to level: ", global.level)

func DoChange():
	change = false
	get_tree().reload_current_scene()

func Explode(arg : Vector2):
	var xpl = SceneExplo.instance()
	xpl.position = arg
	xpl.get_node("AudioStreamPlayer").pitch_scale = rand_range(0.9, 1.1)
	add_child(xpl)
