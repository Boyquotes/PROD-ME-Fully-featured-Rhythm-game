extends Control

var color = EDITOR_C.DEFAULT_COLOR

var bars = []
var bars_data
var bars_count = 0
var real_size
var start_pos = 0
var curr_scale = 1

var size_updated = false
var start_pos_updated = true
var is_active = false

var bar_scn = preload("res://editor/bar.tscn")
onready  var bars_c = get_node("BarsCont")
onready  var editor = get_node("/root/editor")

func _ready():
	spawn_bars()
	set_process(true)

func _process(_delta):

	if real_size != null and not size_updated:
		update_size()
		size_updated = true

	if not start_pos_updated:
		update_start_position()
		start_pos_updated = true

# warning-ignore:shadowed_variable
func setup(bars_count, update_existing = false):
	self.bars_count = bars_count
	if update_existing:respawn_bars()

func spawn_bars():
	clear_bars()
	var x = 0
	
	if bars_data != null:
		for data in bars_data:
			var bar = add_bar(x, int(data.index), int(data.quarters_count))
			bar.set_notes_data(data.notes)
			x += bar.get_width()
	else :
		for i in range(bars_count):
			var bar = add_bar(x, i, EDITOR_C.QUARTERS_COUNT)
			x += bar.get_width()

func respawn_bars():
	var curr_bars_count = bars.size()
	if curr_bars_count < bars_count:
		var x = bars[curr_bars_count - 1].get_position().x + bars[curr_bars_count - 1].get_width()
		for i in range(bars_count):
			if i >= curr_bars_count:
				var bar = add_bar(x, i, EDITOR_C.QUARTERS_COUNT)
				x += bar.get_width()

		print("curr_bars_count < bars_count", " bars count:", bars.size())
	elif curr_bars_count > bars_count:
		for i in range(curr_bars_count):
			if i >= bars_count:bars_c.remove_child(bars[i])
			
		bars.resize(bars_count)
		print("curr_bars_count > bars_count", " bars count:", bars.size())

func set_info():
	color = Color.orange
	real_size = get_custom_minimum_size()

func update_size():
	set_custom_minimum_size(real_size)
	bars_c.show()

func get_height():
	return EDITOR_C.TRACKS_DISTANCE + get_max_bar_height()

func update_scale(val):
	curr_scale = val
	for b in bars:
		b.update_scale(val)
	bars_c.set_position(Vector2(start_pos * val, bars_c.get_position().y))

func clear_bars():
	for b in bars:
		bars_c.remove_child(b)
	bars = []

func add_bar(x, index, quarters_count):
	var bar = bar_scn.instance()
	bar.index = index
	bar.quarters_count = quarters_count
	bar.set_x_position(x)
	bars.append(bar)
	bars_c.call_deferred("add_child", bar)
	return bar


func get_data():
# warning-ignore:shadowed_variable
	var bars_data = []
	for b in bars:
		bars_data.append({
			index = b.index, 
			quarters_count = b.quarters_count, 
			notes = b.get_notes_data()
		})

	return {
		color = color.to_html(), 
		bars = bars_data
	}

func set_data(track_data):
	color = Color(track_data.color)
	bars_data = track_data.bars

func set_start_position(val):
	start_pos = val
	start_pos_updated = false

func update_start_position():
	bars_c.set_position(Vector2(start_pos * curr_scale, bars_c.get_position().y))

func update_height():
	set_custom_minimum_size(Vector2(get_size().x, get_height()))
	editor.update_cursor_length()

func get_max_bar_height():
	var max_h = 0
	for b in bars:
		var h = b.get_height()
		if h > max_h:max_h = h
	return max_h


func _on_name_control_gui_input(e):
	if editor and editor.grab_cursor_slider_focus(e):
		return 
	if (e is InputEventMouseButton and e.button_index == BUTTON_LEFT and e.pressed) or (e is InputEventScreenTouch):
		if is_active:editor.unset_active_track()
		else :editor.set_active_track(self)
		print("HANDLED!")

func set_active(val):
	is_active = val

