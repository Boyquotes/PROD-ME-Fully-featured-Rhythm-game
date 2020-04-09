extends Spatial
#
func _ready():
#	var scale = SETTINGS._settings.player.aproach_speed
#	var new_scale = scale  * 0.01
#	self.set_scale(Vector3(1, 1 - new_scale, 1))
#	self.translate(Vector3(0, 0.452, 0))
	var scale = get_parent().get_scale()
	self.set_scale(Vector3(1/scale.x, 1/scale.y, 1/scale.z)) #3D
