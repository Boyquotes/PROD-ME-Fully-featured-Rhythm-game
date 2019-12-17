extends Spatial

var short_note_scene = preload("res://note/short_note.tscn")
var long_note_scene = preload("res://note/long_note.tscn")

var note_scale
var bar_data
var speed

func _ready():
	add_notes()

func add_notes():
	var line = 1
	for line_data in bar_data:
		var notes_data = line_data.notes
		for note_data in notes_data:
			add_note(line, note_data)
		line += 1
		
func add_note(line, data):
	var note_scene
	#print(data.len)
	if int(data.len) >= 400:
		note_scene = long_note_scene
	else:
		note_scene = short_note_scene
		
	var note = note_scene.instance()
	note.line = line
	note.position = int(data.pos)
	note.length = int(data.len)
	note.length_scale = note_scale
	note.speed = speed
	add_child(note)
	