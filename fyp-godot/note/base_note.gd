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
	
func _on_process(_delta):
	pass
	
func _ready():
	_on_ready()
	
func _on_ready():
	set_position()
	add_listeners()
	
func hit():
	$MeshInstance.hide()
	is_hit = true
	gate.is_hitting = false
	gate.note_hit = self
	#var n = get_node("highway")
	#print(get_parent().get_name())
	ui.hit_feedback(accuracy)
	ui.add_score()

	
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
# warning-ignore:return_value_discarded
	$Area.connect("area_entered", self,"_on_area_entered")

func _on_area_entered(area):
	if is_hit: return
	
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
	elif area.is_in_group("gate_miss"):
		accuracy = 4
		is_colliding = true
		gate = area.get_parent()
	elif area.is_in_group("gate_miss_late"):
		accuracy = 4
		#is_colliding = false
		gate = area.get_parent()
		hit()
