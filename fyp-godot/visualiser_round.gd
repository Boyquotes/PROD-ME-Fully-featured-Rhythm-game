extends Node2D

onready var spectrum = AudioServer.get_bus_effect_instance(0, 0)
export var radius = 250
export var length = 200
export var definition = 32
export var is_circle = false
export var total_w = 400
export var total_h = 200
export var rotate = true
export var cycle_colors = false
export var color = Color("#dde5e9")

var min_freq = 20
var max_freq = 15000

var max_db = 0
var min_db = -50

var accel = 20
var rotate_accel = 10
var histogram = []

var hue_timer = 0
var deg_speed = 60

func _ready():
	for _i in range(definition):
		histogram.append(0)
		
func _process(delta):
	var freq = min_freq
	var interval = (max_freq - min_freq) / definition
	
	for i in range(definition):
		
		var freq_range_low = float(freq - min_freq) / float(max_freq - min_freq)
		freq_range_low = freq_range_low * freq_range_low * freq_range_low * freq_range_low
		freq_range_low = lerp(min_freq, max_freq, freq_range_low)
		
		freq += interval
		
		var freq_range_high = float(freq - min_freq) / float(max_freq - min_freq)
		freq_range_high = freq_range_high * freq_range_high * freq_range_high * freq_range_high
		freq_range_high = lerp(min_freq, max_freq, freq_range_high)
		
		var mag = spectrum.get_magnitude_for_frequency_range(freq_range_low, freq_range_high)
		mag = linear2db(mag.length())
		mag = (mag - min_db) / (max_db - min_db)
		
		mag += 0.3 * (freq - min_freq) / (max_freq - min_freq)
		mag = (clamp(mag, 0.01, 1))
		
		histogram[i] = lerp(histogram[i], mag, accel * delta)
	update()
	
	if rotate == true:
		rotate(delta / rotate_accel)
	
	if cycle_colors == true:
		hue_timer = fmod(hue_timer + delta * deg_speed, 360)
		var h = hue_timer / 360 
		
		var new_color = Color()
		new_color.v = 1
		new_color.s = 1
		new_color.h = h
		
		set_modulate(new_color)
		
func _draw():
	if is_circle == true:
		var angle = PI
		var angle_interval = 2 * PI / definition
		var radius = 50
		var length = 50
	
		for i in range(definition):
			var normal = Vector2(0, -1).rotated(angle)
			var start_pos = normal * radius
			var end_pos = normal * (radius + histogram[i] * length)
			draw_line(start_pos, end_pos, color, 1, true)
			angle += angle_interval
	else:
		var draw_pos = Vector2(0, 0)
		var w_interval = total_w / definition
		
		for i in range(definition):
			draw_line(draw_pos, draw_pos + Vector2(0, -histogram[i] * total_h), color, 1, true)
			draw_pos.x += w_interval
		
