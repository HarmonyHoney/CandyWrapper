extends Node2D

var ScenePlayer = load("res://Scene/Player.tscn")
var SceneGoober = load("res://Scene/Goober.tscn")
var SceneTitle = load("res://Scene/Title.tscn")
var SceneFinish = load("res://Scene/Finish.tscn")

var NodeTileMap
@onready var NodeGoobers := $Goobers
@onready var NodeAudioWin := $Audio/Win
@onready var NodeAudioLose := $Audio/Lose
@onready var NodeAudioMusic := $Audio/Music

var check = false
var count = 0

var delay = 1.5
var change = false

enum {TILE_WALL = 0, TILE_PLAYER = 1, TILE_GOOBER = 2}

var tmpath = "res://TileMap/TileMap"

func _ready():
	global.Game = self
	
	if global.level == 0:
		add_child(SceneTitle.instantiate())
	elif global.level == 21:
		add_child(SceneFinish.instantiate())
	
	MapLoad()
	MapStart()
	
	await get_tree().create_timer(0.1).timeout
	NodeAudioMusic.play()

func _process(delta):
	# quit the game
	if btn.p("ui_cancel"):
		get_tree().quit()
	
	if global.level == 0:
		if btn.p("ui_select"):
			global.level += 1
			DoChange()
	if global.level == 21:
		if btn.p("ui_select"):
			global.level = 1
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
		match NodeTileMap.get_cell_source_id(0, pos):
			TILE_WALL:
				print(pos, ": Wall")
				var atlas = Vector2(2, 2)
				atlas.x = randf_range(0, 3)
				atlas.y = randf_range(0, 3)
				atlas = atlas.floor()
				#NodeTileMap.set_cell(0, pos, TILE_WALL)
			TILE_PLAYER:
				print(pos, ": Player")
				var plr = ScenePlayer.instantiate()
				plr.position = NodeTileMap.map_to_local(pos)
				plr.position.x += 4
				plr.name = "Player"
				add_child(plr)
				# remove tile from map
				NodeTileMap.set_cell(0, pos, -1)
			TILE_GOOBER:
				print(pos, ": Goober")
				var gbr = SceneGoober.instantiate()
				gbr.position = NodeTileMap.map_to_local(pos)
				gbr.position.x += 4
				NodeGoobers.add_child(gbr)
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
	if !check:
		return
	# start check
	check = false
	count = NodeGoobers.get_child_count()
	print("Goobers: ", count)
	if count == 0:
		Win()

func Lose():
	change = true
	NodeAudioLose.play()
	global.level = max(1, global.level - 1)

func Win():
	change = true
	NodeAudioWin.play()
	global.level = min(global.lastLevel, global.level + 1)
	print("Level Complete!, change to level: ", global.level)

func DoChange():
	change = false
	get_tree().reload_current_scene()
