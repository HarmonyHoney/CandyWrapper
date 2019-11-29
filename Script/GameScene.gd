extends Node2D

var ScenePlayer = load("res://Scene/Player.tscn")
var SceneGoober = load("res://Scene/Goober.tscn")

var NodeTileMap
var NodeGoobers

var check = false
var count = 0

var delay = 1.5
var change = false

enum {TILE_WALL = 0, TILE_PLAYER = 1, TILE_GOOBER = 2}

func _ready():
	NodeTileMap = get_node("TileMap")
	NodeGoobers = get_node("Goobers")
	
	MapStart()

func _process(delta):
	# quit the game
	if btn.p("ui_cancel"):
		get_tree().quit()
	
	MapChange(delta)
	

func MapStart():
	print("--- MapStart: Begin ---")
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
				add_child(plr)
				# remove tile from map
				NodeTileMap.set_cellv(pos, -1)
			TILE_GOOBER:
				print(pos, ": Goober")
				var gbr = SceneGoober.instance()
				gbr.position = NodeTileMap.map_to_world(pos)
				gbr.position.x += 4
				add_child(gbr)
				# remove tile from map
				NodeTileMap.set_cellv(pos, -1)
	print("--- MapStart: End ---")

func MapChange(delta):
	# if its time to change scene
	if change:
		delay -= delta
		if delay < 0:
			get_tree().reload_current_scene()
		return # skip the rest if change == true
	
	# should i check?
	if !check:
		return
	# start check
	check = false
	count = NodeGoobers.get_child_count()
	print("ListGoober: ", count)
	if count == 0:
		change = true