extends Button

var playing = false
func _ready():
	set_playing(false)

func set_playing(value):
	playing = value
	if playing == false:
		set_text("Play")
	else :
		set_text("Stop")
