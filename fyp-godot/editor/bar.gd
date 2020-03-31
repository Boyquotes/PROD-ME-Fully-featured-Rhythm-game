extends Node2D

var quarters_count = EDITOR_C.QUARTERS_COUNT
var index = 0

onready  var grid = get_node("Grid")
onready  var index_label = get_node("IndexLabel")
onready  var control = get_node("Control")
onready  var track = get_node("../../")
onready  var editor = get_node("/root/editor")

var note_scn = preload("res://editor/note.tscn")

var filled_cells = []
var notes = []
var x_pos = 0

func _ready():
	index_label.set_text(str(index))
	control.set_custom_minimum_size(Vector2(get_width(), get_height()))

func get_width():
	return get_cells_count() * EDITOR_C.CELL_WIDTH
func get_grid_height():
	return EDITOR_C.CELL_HEIGHT
func get_height():
	return (get_grid_height() * EDITOR_C.HEIGHT)
func get_cells_count():
	return quarters_count * EDITOR_C.CELLS_IN_QUARTER_COUNT
	
func set_x_position(val):
	x_pos = val
	set_position(Vector2(x_pos, 0))

func update_scale(val):
	set_scale(Vector2(val, 1))
	set_position(Vector2(x_pos * val, get_position().y))
	index_label.set_scale(Vector2(1.0 / val, 1))
	for n in notes:n.update_scale(val)

func add_note(x):
	filled_cells.append(int(x))
	var n = note_scn.instance()
	n.set_position(Vector2(x, 0))
	notes.append(n)
	add_child(n)
	sort_notes()
	update_notes_width()
	return n


func clear_notes():
	for n in notes:
		remove_child(n)
	notes = []
	filled_cells = []

func set_notes_data(notes_data):
	clear_notes()
	for data in notes_data:
		var x = int(int(data.pos) / EDITOR_C.CELL_EXPORT_SCALE)
		var n = add_note(x)
		n.set_width(int(data.len) / EDITOR_C.CELL_EXPORT_SCALE)

func get_notes_data():
	var notes_data = []
	for n in notes:
		notes_data.append({
			pos = n.get_position().x * EDITOR_C.CELL_EXPORT_SCALE, 
			len = n.get_width() * EDITOR_C.CELL_EXPORT_SCALE, 
		})
	return notes_data

func sort_notes():
	for i in range(notes.size() - 1, - 1, - 1):
		for j in range(1, i + 1, 1):
			if notes[j - 1].get_position().x > notes[j].get_position().x:
				var t = notes[j - 1]
				notes[j - 1] = notes[j]
				notes[j] = t

func is_cell_empty_at(x):
	if filled_cells.has(x):return false
	for n in notes:
		if x >= n.get_position().x and x < n.get_position().x + n.get_width():
			return false

	return true

func update_notes_width():
	for n in notes:
		n.max_width = calc_note_max_width(n.get_position().x)

func calc_note_max_width(note_x):
	
	var end_note_x = note_x + EDITOR_C.CELL_WIDTH
	var max_note_w = get_width() - note_x
	
	for x in range(end_note_x, get_width(), EDITOR_C.CELL_WIDTH):
		if filled_cells.has(int(x)):
			print("filled cells has", x)
			max_note_w = x - note_x
			break
	return max_note_w

func delete_note(note):
	print("delete note begin", filled_cells)
	filled_cells.erase(int(note.get_position().x))
	update_notes_width()
	remove_child(note)
	notes.erase(note)
	editor.unset_active_note()
	print("deleted!", filled_cells)

func get_first_note():
	if notes.size() == 0:return null
	var first = notes[0]
	for n in notes:
		if n.get_position().x < first.get_position().x:
			first = n
	return first

func get_next_bar():
	if track.bars.size() > index + 1:
		return track.bars[index + 1]
	else :return null

func get_note_after(x_pos):
	if notes.size() > 0:
		var next = []
		for n in notes:
			if n.get_position().x > x_pos:
				next.append(n)
		if next.size() > 0:
			var first = next[0]
			for nn in next:
				if nn.get_position().x < first.get_position().x:
					first = nn
			return first
	return null

func _on_Control_gui_input(e):
	if editor and editor.grab_cursor_slider_focus(e):
		return 
		
	if (e is InputEventMouseButton and e.button_index == BUTTON_LEFT and e.pressed) or (e is InputEventScreenTouch):
		print("bar " + str(index) + " Clicked at", e.position)
		var i = floor(e.position.x / float(EDITOR_C.CELL_WIDTH))
		var x = i * EDITOR_C.CELL_WIDTH
		if is_cell_empty_at(x):
			var note = add_note(x)
			editor.set_active_note(note)
