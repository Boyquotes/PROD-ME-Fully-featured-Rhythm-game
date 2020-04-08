extends Spatial

var bar_scene = preload("res://bar.tscn")
var bars = []
onready var bars_node = $BarsNode
var bar_length
var curr_location
var speed
var note_scale

var curr_bar_ind
var track_data
var scaled_bar_amnt
var max_indx
var game

# warning-ignore:shadowed_variable
func setup(game):
	self.game = game
	speed = Vector3(0,0,game.speed)
	bar_length = game.bar_length
	curr_location = Vector3(0,0,-bar_length)
	note_scale = game.note_scale
	curr_bar_ind = 0
	track_data = game.map.tracks
	scaled_bar_amnt = max(ceil(32 / bar_length), 1)
	max_indx = 0
	for t in track_data:
		max_indx = max(max_indx, len(t.bars))
		
	add_bars(scaled_bar_amnt)

func _process(delta):
	bars_node.translate(speed*delta)
	for bar in bars:
		if bar.translation.z + bars_node.translation.z >= bar_length:
			remove_bar(bar)
			add_bar()

func add_bar():
	if (curr_bar_ind >= max_indx): 
		return
	var bar = bar_scene.instance()
	bar.translation = Vector3(curr_location.x, curr_location.y, curr_location.z)
	bar.note_scale = note_scale
	bar.bar_data = get_bar_data()
	bar.speed = speed
	bars.append(bar)
	bars_node.add_child(bar)
	curr_location += Vector3(0,0,-bar_length)
	curr_bar_ind +=1
	
func get_bar_data():
	var line1_data = track_data[0].bars[curr_bar_ind]
	#print(line1_data)
	var line2_data = track_data[1].bars[curr_bar_ind]
	#print(line2_data)
	var line3_data = track_data[2].bars[curr_bar_ind]
	#print(line3_data)
	var line4_data = track_data[3].bars[curr_bar_ind]
	#print(line4_data)
	return [line1_data, line2_data, line3_data, line4_data]
	
	
func remove_bar(bar):
	#print("REMOVING BAR")
	bar.queue_free()
	bars.erase(bar)
	if(len(bars) == 0) and curr_bar_ind == max_indx:
		game.get_node("ui_node").is_finished()
		game.map_finished()
	
func add_bars(var l):
	for _i in range(l):
		add_bar()
