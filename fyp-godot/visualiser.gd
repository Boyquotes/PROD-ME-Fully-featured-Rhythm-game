extends Node2D

onready var spectrum = AudioServer.get_bus_effect_instance(0, 0)

var definition = 100
var total_w = 900
var total_h = 500
var min_freq = 20
var max_freq = 20000

var max_db = 0
var min_db = -50

var accel = 10
var histogram = []

func _ready():
	max_db += get_parent().volume_db
	min_db += get_parent().volume_db
	
	for i in range(definition):
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
		mag = (clamp(mag, 0.005, 1))
		
		histogram[i] = lerp(histogram[i], mag, accel * delta)
		
	update()
		
func _draw():
	var draw_pos = Vector2(0,0)
	var w_interval = total_w / definition
	
	draw_line(Vector2(0, -total_h), Vector2(total_w, -total_h), Color.aqua, 2.0, true)
	
	for i in range(definition):
		draw_line(draw_pos, draw_pos + Vector2(0, -histogram[i] * total_h), Color.aqua, 4.0, true)
		
		draw_pos.x += w_interval
		
	
