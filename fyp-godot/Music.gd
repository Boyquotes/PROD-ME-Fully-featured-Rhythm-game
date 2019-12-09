extends Spatial

onready var player = $AudioStreamPlayer

var speed
var started
var pre_start_duration
var start_pos

func _ready():
	pass
	
func setup(game):
	player.stream = game.audio
	
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
			