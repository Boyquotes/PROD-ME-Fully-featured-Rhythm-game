extends Spatial

onready var player = $AudioStreamPlayer

var speed
var started
var pre_start_duration
var start_pos
var audio_file = GAME_C.map_selected.audio_file
var audio

func _ready():
	play_song(audio_file)
	
func play_song(path):
	var ogg_file = File.new()
	ogg_file.open(path, File.READ)
	var bytes = ogg_file.get_buffer(ogg_file.get_len())
	var stream = AudioStreamOGGVorbis.new()
	stream.data = bytes
	ogg_file.close()
	player.set_stream(stream)
	
func setup(game):
	player.stream.set_loop(false)
	speed = game.speed
	started = false
	pre_start_duration = game.bar_length
	start_pos = game.start_pos
	
func start():
	started = true
	player.play(start_pos)
	
func _process(delta):
	if not started:
		pre_start_duration -= speed*delta
		if pre_start_duration <= 0:
			start()
			return
