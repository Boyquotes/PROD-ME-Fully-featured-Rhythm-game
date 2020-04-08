extends Spatial

onready var music_node = get_node("music")
onready var highway_node = get_node("highway")
onready var user_int = get_node("ui_node")
onready var loading_screen = get_node("OverlayLayer/LoadingScreen")

var audio
var map
var audio_file
var map_file

var tempo
var bar_length
var quarter_time
var speed
var note_scale
var start_pos
export var ar = 200
var score = 0
var combo = 0

var map_thread = Thread.new()
var load_percent = 0

func _ready():
	load_game()
		
func load_game():
	map_thread.start(self, "build_map", null, 1)
	set_vars()
	calc_params()
	setup_nodes()
	
func set_vars():
	audio_file = GAME_C.map_selected.audio_file
	map_file = GAME_C.map_selected.map_file
	audio = load(audio_file)
	map = load_map()
	load_percent += 25
	loading_screen.update_percent(load_percent)
	
func calc_params():
	tempo = int(map.tempo)
	bar_length = 8 * float(float(ar) / tempo)
	quarter_time = 60/float(tempo)
	speed = bar_length/float(4*quarter_time)
	note_scale = bar_length/float(4*400)
	start_pos = (float(map.start_pos)/400.0) * quarter_time
	load_percent += 25
	loading_screen.update_percent(load_percent)
	
func load_map():
	var file = File.new()
	file.open(map_file, File.READ)
	var content = file.get_as_text()
	file.close()
	load_percent += 25
	loading_screen.update_percent(load_percent)
	return JSON.parse(content).get_result()
	
func setup_nodes():
	music_node.setup(self)
	highway_node.setup(self)
	load_percent += 25
	loading_screen.update_percent(load_percent)
	
func build_map(_empty):
	load_percent += 25
	loading_screen.update_percent(load_percent)
	map_thread.wait_to_finish()

func map_finished():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://menu/map_finish_menu.tscn")
	
