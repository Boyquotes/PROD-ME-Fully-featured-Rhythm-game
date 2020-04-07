extends ConfirmationDialog

signal map_info_saved

const AUDIO_FIELD_NAMES = [
	"TITLE",
	"ARTIST"
]

var audio_info = {}
var audio_file_name = ""
var creator
var session_file_path = "user://editor/session"
var session_data = {}

onready  var creator_input = get_node("VBoxContainer/Creator_input")
onready  var artist_input = get_node("VBoxContainer/Artist_input")
onready  var title_input = get_node("VBoxContainer/Title_input")

func setup(audio_file_name, audio_comments):
	self.audio_file_name = audio_file_name
	init_audio_inputs(audio_comments)
	init_map_inputs()

func init_audio_inputs(audio_comments):
	parse_audio_comments(audio_comments)
	if title_input.get_text() == "":
		title_input.set_text(audio_file_name)

func init_map_inputs():
	session_data = Utils.read_json_file(session_file_path)
	if not session_data:
		session_data = {}
		return 
	creator = str(session_data.creator)
	creator_input.set_text(creator)

func set_audio_inputs_from(data):
	artist_input.set_text(data["artist"])
	title_input.set_text(data["title"])

	if title_input.get_text() == "":
		title_input.set_text(audio_file_name)

func parse_audio_comments(audio_comments):
	for c in audio_comments:
		for f in AUDIO_FIELD_NAMES:
			if c.to_upper().find(str(f) + "=") != - 1 and c.split("=").size() > 1:
				var val = c.split("=")[1]
				var node_name = f.to_lower().capitalize()
				var audio_c = get_node("VBoxContainer")
				if audio_c.has_node(node_name):
					var n = audio_c.get_node(node_name)
					n.set_text(val)
				break
				
func apply_audio_inputs():
	audio_info["artist"] = artist_input.get_text()
	audio_info["title"] = title_input.get_text()

func apply_map_inputs():
	creator = creator_input.get_text()
	session_data["creator"] = creator
	Utils.write_json_file(session_file_path, session_data)

func set_data(creator_data, audio_data):
	creator_input.set_text(str(creator_data))
	set_audio_inputs_from(audio_data)
	apply_map_inputs()
	apply_audio_inputs()

func _on_MapInfo_confirmed():
	if creator_input.get_text() == "" or title_input.get_text() == "":
		var pos = get_position()
		popup()
		set_position(pos)
		return
		
	apply_map_inputs()
	apply_audio_inputs()
	emit_signal("map_info_saved")
