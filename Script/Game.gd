extends Node2D

var tmpath = "res://TileMap/"
enum {TILE_WALL = 0, TILE_PLAYER = 1, TILE_GOOBER = 2}

var ScenePlayer = load("res://Scene/Player.tscn")
var SceneGoober = load("res://Scene/Goober.tscn")
var SceneTitle = load("res://Scene/Title.tscn")
var SceneFinish = load("res://Scene/Finish.tscn")

var NodeTileMap
@onready var NodeGoobers := $Goobers
@onready var NodeAudioWin := $Audio/Win
@onready var NodeAudioLose := $Audio/Lose
@onready var NodeSprite := $Sprite2D

var check = false

var clock := 0.0
var delay = 1.5
var change = false

func _ready():
	global.Game = self
	
	if global.level == 0:
		add_child(SceneTitle.instantiate())
	elif global.level == 21:
		add_child(SceneFinish.instantiate())
	
	MapLoad()
	MapStart()

func _process(delta):
	clock += delta
	# title and finish
	if btn.p("jump") and (global.level == 0 or (global.level == 21  and clock > 0.5)):
		global.level = posmod(global.level + 1, 22)
		DoChange()
	
	MapChange(delta)

func MapLoad():
	var nxtlvl = min(global.level, global.lastLevel)
	var tm = load(tmpath + str(nxtlvl) + ".tscn").instantiate()
	tm.name = "TileMap"
	add_child(tm)
	NodeTileMap = tm

func MapStart():
	print("--- MapStart: Begin ---")
	print("global.level: ", global.level)
	for pos in NodeTileMap.get_used_cells(0):
		var id = NodeTileMap.get_cell_source_id(0, pos)
		if id == TILE_WALL:
			print(pos, ": Wall")
			var atlas = Vector2(randf_range(0, 3), randf_range(0, 3))
			atlas = atlas.floor()
			#NodeTileMap.set_cell(0, pos, TILE_WALL)
		elif id == TILE_PLAYER or id == TILE_GOOBER:
			var p = id == TILE_PLAYER
			print(pos, ": Player" if p else ": Goober")
			var inst = (ScenePlayer if p else SceneGoober).instantiate()
			inst.position = NodeTileMap.map_to_local(pos) + Vector2(4, 0)
			(self if p else NodeGoobers).add_child(inst)
			# remove tile from map
			NodeTileMap.set_cell(0, pos, -1)
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
	NodeAudioLose.play()
	NodeSprite.visible = true
	NodeSprite.frame = 2
	global.level = max(0, global.level - 1)

func Win():
	change = true
	NodeAudioWin.play()
	NodeSprite.visible = true
	global.level = min(global.lastLevel, global.level + 1)
	print("Level Complete!, change to level: ", global.level)

func DoChange():
	change = false
	get_tree().reload_current_scene()
