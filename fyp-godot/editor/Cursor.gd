extends Node2D

const DEFAULT_LENGTH_OFFSET = 30
const STATIC_COLOR = Color("#cfaa38")
const PLAYBACK_COLOR = Color("ffffff")

var speed = 0
var speed_scale = 1
var curr_speed = 0
export  var is_static = false

var length = EDITOR_C.WAVEFORM_H
var length_offset = 0

func _ready():
	set_process(true)

func start():
	curr_speed = speed

func stop():
	curr_speed = 0

func _process(_delta):
	pass

func set_length_offset(val):
	length_offset = val
	update()

func _draw():
	if is_static:
		var pointer = PoolVector2Array()
		pointer.push_back(Vector2(5, 0))
		pointer.push_back(Vector2( -5, 0))
		pointer.push_back(Vector2(0, 5))
		draw_colored_polygon(pointer, STATIC_COLOR)
		draw_line(Vector2(0, 0), Vector2(0, length + length_offset + DEFAULT_LENGTH_OFFSET), STATIC_COLOR, 1)
	else :
		draw_line(Vector2(0, 0), Vector2(0, length + length_offset + DEFAULT_LENGTH_OFFSET), PLAYBACK_COLOR, 1)

