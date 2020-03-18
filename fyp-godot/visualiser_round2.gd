extends Node2D

onready var spectrum = AudioServer.get_bus_effect_instance(0, 0)

var definition = 150
var min_freq = 20
var max_freq = 15000

var max_db = 0
var min_db = -50

var accel = 20
var histogram = []

func _ready():
	max_db += get_parent().volume_db
	min_db += get_parent().volume_db
	
	for i in range(definition):
		histogram.append(0)
		
func _process(delta):
	var freq = min_freq
	var interval = (max_freq - min_freq) / definition
	
	rotate(1.0)
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
		mag = (clamp(mag, 0.0075, 1))
		
		histogram[i] = lerp(histogram[i], mag, accel * delta)
		
	update()
		
func _draw():
	var angle = PI
	var angle_interval = 2 * PI / definition
	var radius = 250
	var length = 150
	var color = Color(255,255,255)
	for i in range(definition):
		var normal = Vector2(0 , -1).rotated(angle)
		var start_pos = normal * radius
		var end_pos = normal * (radius + histogram[i] * length)
		draw_line(start_pos, end_pos, color, 8.0, true)
		angle += angle_interval
