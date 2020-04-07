extends VideoPlayer


func _ready():      
	set_process(true)
	
func _process(_delta):
	if not is_playing():
		play()
