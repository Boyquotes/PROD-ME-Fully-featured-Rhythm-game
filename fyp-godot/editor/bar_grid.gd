extends Node2D

const LINE_COLOR = Color("#242424")
const LINE_WIDTH = 1
const BG_COLOR = Color("#3d3e40")

onready  var bar = get_node("../")

func _ready():
	update()

func get_bg_color():
	var color_value = bar.index / 4.0 - floor(bar.index / 4.0)
	return BG_COLOR.linear_interpolate(Color(0.2, 0.2, 0.2), color_value)

func _draw():
	var rect = Rect2(0, 0, bar.get_width(), bar.get_grid_height())
	draw_rect(rect, get_bg_color())

	var cell_counter = 0
	for x in range(bar.get_cells_count() + 1):
		var col_pos = x * EDITOR_C.CELL_WIDTH

		var color = LINE_COLOR
		if cell_counter > 0 and cell_counter < 4:color.a = 0.2
		cell_counter += 1
		if cell_counter >= 4:cell_counter = 0
		draw_line(Vector2(col_pos, 0), Vector2(col_pos, bar.get_grid_height()), color, LINE_WIDTH)
		
	for y in range(2):
		var row_pos = y * EDITOR_C.CELL_HEIGHT
		draw_line(Vector2(0, row_pos), Vector2(bar.get_width(), row_pos), LINE_COLOR, LINE_WIDTH)
