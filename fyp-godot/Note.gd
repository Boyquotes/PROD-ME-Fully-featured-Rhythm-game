extends Spatial

export(int, 1, 4) var line
var position = 0
var is_colliding = false
var is_hit = false
var gate

func _process(delta):
	hit()
	
func _ready():
	set_position()
	
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
	self.translation = Vector3(x,0,position)
	
func hit():
	if not is_hit:
		if is_colliding and gate:
			if gate.is_hitting:
				is_hit = true
				gate.is_hitting = false
				hide()

func _on_area_entered(area):
	if area.is_in_group("gate"):
		is_colliding = true
		gate = area.get_parent()
		

func _on_area_exited(area):
	if area.is_in_group("gate"):
		is_colliding = false
