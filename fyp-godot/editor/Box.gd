extends Node2D

var outline_col = Color("292929")
var fill_col = Color("3e3e3e")
export var is_outline = false

func _process(_delta):
	update()
	
func _draw():
	if is_outline == true:
		draw_line(Vector2(0, -60), Vector2(256, -60), outline_col, 1, true)
		draw_line(Vector2(0, -1), Vector2(256, -1), outline_col, 1, true)
		draw_line(Vector2(0, -1), Vector2(0, -60), outline_col, 1, true)
		draw_line(Vector2(256, -1), Vector2(256, -60), outline_col, 1, true)
	else:
		var rect = Rect2(Vector2(0,-60),Vector2(256,60))
		draw_rect(rect, fill_col)
