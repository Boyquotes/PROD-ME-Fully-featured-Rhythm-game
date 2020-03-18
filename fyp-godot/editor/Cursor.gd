extends Node2D

const DEFAULT_LENGTH_OFFSET = 30
const COLOR = Color("#ff66e3")

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
		pointer.push_back(Vector2(10, 0))
		pointer.push_back(Vector2( - 10, 0))
		pointer.push_back(Vector2(0, 10))
		draw_colored_polygon([Vector2(12, 0), Vector2( - 12, 0), Vector2(0, 12)], Color(0, 0, 0, 0.2))
		draw_line(Vector2(0, 0), Vector2(0, length + length_offset + DEFAULT_LENGTH_OFFSET), Color(0, 0, 0, 0.3), 4)	
		draw_colored_polygon(pointer, COLOR)
		draw_line(Vector2(0, 0), Vector2(0, length + length_offset + DEFAULT_LENGTH_OFFSET), COLOR, 2)
	else :
		draw_line(Vector2(0, 0), Vector2(0, length + length_offset + DEFAULT_LENGTH_OFFSET), COLOR, 2)

