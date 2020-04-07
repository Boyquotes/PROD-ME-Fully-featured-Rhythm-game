extends Control

onready var scroll_cont = get_node("ScrollContainer")

var list_item = preload("res://menu/SongDisplay.tscn")
var list_index = 0
var songs_dir = "songs/"
var song_files

func _ready():
	parse_songs_dir()
	parse_song_files()
	add_list()

func add_list():
	for song in song_files:
		var item = list_item.instance()
		item.get_node("details/SongName").text = str(song.audio.title)
		item.get_node("details/Artist").text = str(song.audio.artist)
		item.get_node("details/Creator").text = str(song.creator)
		item.rect_min_size = Vector2(400, 110)
		scroll_cont.get_node("VBoxContainer").add_child(item)
		item.song = song

func search_dir(dir_name):
	var file_names = []
	var dir = Directory.new()
	var code = dir.open(dir_name)
	if code == 0:
		print("FOLDER OPEN RETURN CODE: ", dir_name, str(code))
	dir.list_dir_begin()

	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			if file_name.ends_with(".json"):
				file_names.append([dir_name, file_name])
		elif file_name != ".." and file_name != ".":
			file_names += search_dir(dir_name + "/" + file_name)
		file_name = dir.get_next()
	
	print("Scanning dir")
	return file_names

func parse_songs_dir():
	song_files = []
	var file_names = []
	var dir = Directory.new()

	var code = dir.open(songs_dir)
	print("OPEN RETURN CODE: " + str(code))
	dir.list_dir_begin()

	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			if file_name.ends_with(".json"):
				file_names.append(["", file_name])
		elif file_name != ".." and file_name != ".":
			file_names += search_dir(songs_dir + file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	print(file_names)
	
func parse_song_files():
	song_files = []
	var file_names = []
	var dir = Directory.new()

	var code = dir.open(songs_dir)
	print("OPEN RETURN CODE: " + str(code))

	dir.list_dir_begin()

	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			if file_name.ends_with(".song"):
				file_names.append(["", file_name])
		elif file_name != ".." and file_name != ".":
			file_names += search_dir(songs_dir + file_name)
		file_name = dir.get_next()

	dir.list_dir_end()
	var song_file_name
	var song_file_dir
	var song_file_path

	var file
	var song_file
	var map_file
	
	for file_name_entry in file_names:
		song_file_dir = file_name_entry[0]
		song_file_name = file_name_entry[1]
		print(song_file_dir + " " + song_file_name)
		song_file_path = song_file_name
		if song_file_dir != "":
			song_file_path = song_file_dir + "/" + song_file_name
		file = File.new()
		file.open(song_file_path, File.READ)
		
		var content = ""
		for i in 5:
			content += file.get_line()
		content = content.substr(0, content.length() - 1) + "}"
		file.close()
		content = JSON.parse(content).get_result()
		content.audio_file = song_file_dir + "/" + content.audio_file
		content.map_file = song_file_dir + "/" + song_file_name
		content.map_directory = song_file_dir + "/"
		song_files.append(content)
