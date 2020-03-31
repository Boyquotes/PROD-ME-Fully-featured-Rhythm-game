extends Node2D
tool 

export  var color = Color(0, 0, 0, 1)
export  var width = 10
export  var height = 10
export  var draw_border = true
export  var border_width = 1

func _ready():
	update()

func _draw():
	if draw_border:
		draw_rect(Rect2(0, 0, width, height), get_border_color())
		draw_rect(Rect2(border_width, border_width, width - border_width * 2, height - border_width * 2), get_bg_color())
	else :
		draw_rect(Rect2(0, 0, width, height), get_bg_color())
		
func get_bg_color():
	return color

func get_border_color():
	return Color(color).linear_interpolate(Color(0, 0, 0), 0.2)


