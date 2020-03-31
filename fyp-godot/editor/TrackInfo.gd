extends ConfirmationDialog

signal track_info_saved

onready  var name_input = get_node("VBoxContainer/LineEdit")
onready  var color_btn = get_node("VBoxContainer/ColorPickerButton")
var track
var track_name
var color

func _ready():
	pass

func setup(track):
	self.track = track
	if track != null:
		set_inputs(track)
	else :
		set_default_inputs()
		
func apply_inputs():
	color = color_btn.color

func set_inputs(track):
	color_btn.color = track.color

func set_default_inputs():
	color_btn.color = EDITOR_C.DEFAULT_COLOR

func _on_TrackInfo_confirmed():
	apply_inputs()
	emit_signal("track_info_saved")
