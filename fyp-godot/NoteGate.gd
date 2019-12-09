extends Spatial

export(int, 1,4) var line

var is_pressed = false
var is_hitting = false

func _ready():
	set_process_input(true)
	
func _input(event):
	match line:
		1:
			if event.is_action_pressed("key1"):
				is_pressed = true
				is_hitting = true
			elif event.is_action_released("key1"):
				is_pressed = false
				is_hitting = false
		2:
			if event.is_action_pressed("key2"):
				is_pressed = true
				is_hitting = true
			elif event.is_action_released("key2"):
				is_pressed = false
				is_hitting = false
		3:
			if event.is_action_pressed("key3"):
				is_pressed = true
				is_hitting = true
			elif event.is_action_released("key3"):
				is_pressed = false
				is_hitting = false
		4:
			if event.is_action_pressed("key4"):
				is_pressed = true
				is_hitting = true
			elif event.is_action_released("key4"):
				is_pressed = false
				is_hitting = false
				
func _process(delta):
	if is_pressed:
		self.scale = Vector3(0.9, 0.9, 0.9)
	else:
		self.scale = Vector3(1,1,1)
		