extends Spatial

onready var music_node = $music
onready var highway_node = $highway

var audio
var map
var audio_file = "res://audio2.ogg"
var map_file = "res://map2.json"

var tempo
var bar_length
var quarter_time
var speed
var note_scale
var start_pos


func _ready():
	audio = load(audio_file)
	map = load_map()
	calc_params()
	
	music_node.setup(self)
	highway_node.setup(self)
	
func calc_params():
	tempo = int(map.tempo)
	bar_length = 8
	quarter_time = 60/float(tempo)
	speed = bar_length/float(4*quarter_time)
	note_scale = bar_length/float(4*400)
	start_pos = (float(map.start_pos)/400.0) * quarter_time
	
func load_map():
	var file = File.new()
	file.open(map_file, File.READ)
	var content = file.get_as_text()
	file.close()
	return JSON.parse(content).get_result()
	