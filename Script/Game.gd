extends Node2D

export var ScenePlayer : PackedScene
export var SceneGoober : PackedScene
export var SceneTitle : PackedScene
export var SceneFinish : PackedScene

var NodeTileMap
var NodeGoobers
var NodeAudioWin
var NodeAudioLose

var check = false
var count = 0

var delay = 1.5
var change = false

enum {TILE_WALL = 0, TILE_PLAYER = 1, TILE_GOOBER = 2}

var tmpath = "res://TileMap/TileMap"

var arcade

func _ready():
	
	NodeGoobers = get_node("Goobers")
	NodeAudioWin = get_node("AudioWin")
	NodeAudioLose = get_node("AudioLose")
	
	if arcade.level == 0:
		add_child(SceneTitle.instance())
	elif arcade.level == arcade.lastLevel:
		add_child(SceneFinish.instance())
	
	
	MapLoad()
	MapStart()
	

func _process(delta):
	# quit the game
	if p("ui_cancel"):
		get_tree().quit()
	
	if arcade.level == 0 or arcade.level == 21:
		if p("ui_select"):
			arcade.level = wrapi(arcade.level + 1, 1, 21)
			DoChange()
	
	MapChange(delta)

func MapLoad():
	var nxtlvl = min(arcade.level, arcade.lastLevel)
	var tm = load(tmpath + String(nxtlvl) + ".tscn").instance()
	tm.name = "TileMap"
	add_child(tm)
	NodeTileMap = get_node("TileMap")
	


func MapStart():
	print("--- MapStart: Begin ---")
	print("arcade.level: ", arcade.level)
	for pos in NodeTileMap.get_used_cells():
		match NodeTileMap.get_cellv(pos):
			TILE_WALL:
				print(pos, ": Wall")
				var atlas = Vector2(2, 2)
				atlas.x = rand_range(0, 3)
				atlas.y = rand_range(0, 3)
				atlas = atlas.floor()
				NodeTileMap.set_cell(pos.x, pos.y, TILE_WALL,
				false, false, false, atlas)
			TILE_PLAYER:
				print(pos, ": Player")
				var plr = ScenePlayer.instance()
				plr.position = NodeTileMap.map_to_world(pos)
				plr.position.x += 4
				plr.name = "Player"
				add_child(plr)
				# remove tile from map
				NodeTileMap.set_cellv(pos, -1)
			TILE_GOOBER:
				print(pos, ": Goober")
				var gbr = SceneGoober.instance()
				gbr.position = NodeTileMap.map_to_world(pos)
				gbr.position.x += 4
				NodeGoobers.add_child(gbr)
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
	arcade.level = max(1, arcade.level - 1)
	arcade.title.visible = true
	arcade.title.frame = 2

func Win():
	change = true
	NodeAudioWin.play()
	arcade.level = min(arcade.lastLevel, arcade.level + 1)
	print("Level Complete!, change to level: ", arcade.level)
	arcade.title.visible = true
	arcade.title.frame = 1

func DoChange():
	change = false
	arcade.start_game()



func NumBool(arg : bool):
	return 1 if arg else 0

# DOWN
func d(arg : String):
	return NumBool(Input.is_action_pressed(arg))

# PRESSED
func p(arg : String):
	return NumBool(Input.is_action_just_pressed(arg))

# RELEASED
func r(arg : String):
	return NumBool(Input.is_action_just_released(arg))
