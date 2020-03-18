extends HBoxContainer

var playing = false
onready var btn = get_node("play_btn")
func _ready():
	set_playing(false)

func set_playing(value):
	playing = value
	if playing == false:
		btn.set_text("Play")
	else :
		btn.set_text("Stop")
