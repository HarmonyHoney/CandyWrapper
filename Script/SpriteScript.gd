extends Sprite

export var file_dir 	= "res://Image/"
export var file_name 	= "frog"
var file_ext = "json"

var LOOP = 0
var NAME = []
var FIRST = []
var LAST = []
var DURATION = []

var timer = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	print("\n---Begin SpriteScript---")
	print("Importing data from ", file_name, ".", file_ext)
	var json = ParseJson()
	if !json.has("meta") || !json.meta.has("version"):
		print("failure")
	
	DURATION = []
	var num = 0
	var key_name = file_name + " " + String(num) + ".aseprite"
	while (json.frames.has(key_name)):
		DURATION.append(json.frames[key_name].duration / 1000)
		num += 1
		key_name = file_name + " " + String(num) + ".aseprite"
	print(file_name + ".aseprite contains: " + String(num - 1) + " frames")
	hframes = DURATION.size()
	print("Durations: ", DURATION, "\n")

	print("Size of frameTags: " + String(json.meta.frameTags.size()))
	for i in json.meta.frameTags.size():
		var thisTag = json.meta.frameTags[i]
		
		NAME.append(thisTag.name)
		FIRST.append(thisTag.from)
		LAST.append(thisTag.to)

	
	for i in range(NAME.size()):
		print("Name: ", NAME[i], ",\t First: ", FIRST[i], ",\t Last: ", LAST[i])
	print("---End of SpriteScript---")


# Called every frame. 'delta' is the elapsed time since the previous frame.
# warning-ignore:unused_argument
func _process(delta):
	# wait for timer
	timer += delta
	if timer < DURATION[frame]:
		return
	timer -= DURATION[frame]
	# post timer
	
	var nFrame = frame + 1
	if nFrame > LAST[LOOP]:
		nFrame = FIRST[LOOP]
	frame = nFrame
	

func ParseJson():
	var file_path = file_dir + file_name + "." + file_ext
	
	var data_file = File.new()
	if data_file.open(file_path, File.READ) != OK:
		print("Error loading" + file_path)
		return
	
	var data_text = data_file.get_as_text()
	data_file.close()
	
	var data_parse = JSON.parse(data_text)
	if data_parse.error != OK:
		print("Error parsing" + file_path)
		return
	
	return data_parse.result

func SetLoop(arg : String):
	var newLoop = -1
	# check the names
	for i in range(NAME.size()):
		if arg == NAME[i]:
			newLoop = i
	# check if a loop has been found
	if newLoop == -1:
		print("SetLoop Error: Name of loop not found!")
		return false # leave the function
	# continuing if no error
	
	LOOP = newLoop
	frame = FIRST[LOOP]
	return true

func GetLoop():
	return NAME[LOOP]

# TryLoop will start a LOOP,
# but only if that LOOP is not playing
func TryLoop(arg : String):
	if arg == NAME[LOOP]:
		return true
	else:
		return SetLoop(arg)







