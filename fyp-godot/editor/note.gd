extends Node2D

const BORDER_LINE_W = 1
const CELL_SCALE_MIN = 0.5

var is_pressed = false
var is_deleted = false
var dragging = false
var playing = false
var is_active = false

var width_scale = 1
var max_width = EDITOR_C.CELL_WIDTH
var last_dragging_y = 0
var start_dragging_y = 0
var updated_scale = 1

onready  var control = get_node("Control")
onready  var bar = get_node("../")
onready  var editor = get_node("/root/editor")


func _ready():
	set_process(true)

func _process(_delta):
	if editor and editor.is_playing:
		var note_x = get_global_position().x
		var cursor_x = editor.cursor_playback.get_global_position().x
		if cursor_x >= note_x and cursor_x <= note_x + max_width * bar.get_scale().x:
			if not playing:
				playing = true
				update()
		elif playing:
			playing = false
			update()

	elif playing:
		playing = false
		update()

func get_border_color():
	return get_note_color().linear_interpolate(Color(0, 0, 0), 0.3)

func get_note_color():
	if is_active or playing:
		return bar.track.color.linear_interpolate(Color(1, 1, 1), 0.8)
	else:
		return bar.track.color

func set_active(val):
	is_active = val
	update()

func get_width():
	return EDITOR_C.CELL_WIDTH * width_scale


func set_width(value):
	width_scale = float(value) / EDITOR_C.CELL_WIDTH
	update()

func _draw():
	var rect2 = Rect2(BORDER_LINE_W, BORDER_LINE_W, get_width() - BORDER_LINE_W * 2, EDITOR_C.CELL_HEIGHT - BORDER_LINE_W * 2)
	draw_rect(rect2, get_border_color())
	var rect = Rect2(BORDER_LINE_W, BORDER_LINE_W, get_width() - BORDER_LINE_W * 3, EDITOR_C.CELL_HEIGHT - BORDER_LINE_W * 3)
	draw_rect(rect, get_note_color())

	control.set_size(Vector2(get_width(), EDITOR_C.CELL_HEIGHT))
	
func delete():
	if not is_deleted:
		is_deleted = true
		bar.delete_note(self)

	var _i = 0
	update_scale(updated_scale)
	
func update_scale(val):
	updated_scale = val

func _on_Control_gui_input(e):
	if editor and editor.grab_cursor_slider_focus(e):
		return 

	if e is InputEventMouseButton and e.button_index == BUTTON_LEFT:
		is_pressed = e.pressed
		if not is_pressed:
			set_position(Vector2(get_position().x, 0))
		if is_pressed and not is_active:
			editor.set_active_note(self)
	
	if e is InputEventMouseMotion:
		if is_pressed:
			if e.position.x > get_width():
				var w = e.position.x
				if w > 0:
					var s = round((w / EDITOR_C.CELL_WIDTH) / CELL_SCALE_MIN) * CELL_SCALE_MIN
					if s >= 1 and s * EDITOR_C.CELL_WIDTH <= max_width:
						width_scale = s
						update()
			elif e.position.x < get_width() - EDITOR_C.CELL_WIDTH:
				var w = EDITOR_C.CELL_WIDTH + e.position.x
				if w > 0:
					var s = round((w / EDITOR_C.CELL_WIDTH) / CELL_SCALE_MIN) * CELL_SCALE_MIN
					if s >= CELL_SCALE_MIN and s * EDITOR_C.CELL_WIDTH <= max_width:
						width_scale = s
						update()
		
	if e is InputEventMouseButton and e.button_index == BUTTON_RIGHT:
		delete()

