extends Spatial


export(int, 1, 4) var line
var position = 0
var length
var length_scale
var speed
var score = 0
var accuracy
var multiplier = 1

var is_colliding = false
var is_hit = false
var gate
onready var ui = get_tree().get_root().get_node("Game").get_node("ui_node")
func _process(delta):
	_on_process(delta)
		
func _on_process(delta):
	pass
	
func hit():
	is_hit = true
	gate.is_hitting = false
	#var n = get_node("highway")
	#print(get_parent().get_name())
	if ui != null:
		ui.hit_feedback(accuracy)
		ui.add_score()
	
func _ready():
	_on_ready()
	
func _on_ready():
	set_position()
	add_listeners()
	
func set_position():
	var x
	match line:
		1:
			x = -1.5
		2:
			x = -0.5
		3:
			x = 0.5
		4: 
			x = 1.5
	self.translation = Vector3(x,0,-position*length_scale)
	
func add_listeners():
	$Area.add_to_group("note")
	$Area.connect("area_entered", self,"_on_area_entered")
	$Area.connect("area_exited", self,"_on_area_exited")

func _on_area_entered(area):
	if area.is_in_group("gate_perfect"):
		accuracy = 1
		is_colliding = true
		gate = area.get_parent()
	elif area.is_in_group("gate_great"):
		accuracy = 2
		is_colliding = true
		gate = area.get_parent()
	elif area.is_in_group("gate_ok"):
		accuracy = 3
		is_colliding = true
		gate = area.get_parent()
	if area.is_in_group("gate_miss"):
		accuracy = 4
		is_colliding = true
		gate = area.get_parent()

func _on_area_exited(area):
	pass
	#if area.is_in_group("gate_perfect"):
		#is_colliding = false
	#elif area.is_in_group("gate_great"):
		#is_colliding = false
	#elif area.is_in_group("gate_ok"):
	#	is_colliding = false
