extends Control

onready var scroll_cont = get_node("ScrollContainer")
onready var leaderboard_cont = get_node("ScoreCont")

var list_item = preload("res://menu/SongDisplay.tscn")
var list_index = 0
var songs_dir = "songs/"
var song_files
var scores
var map_changed = false
var selected_map

var list_leadboard_item = preload("res://menu/ScoreDisplay.tscn")

func _ready():
	parse_songs_dir()
	parse_song_files()
	add_list()
	fetch_api()
	$Player.text = SETTINGS._settings.player.player_name
	
func play_song(path):
	var ogg_file = File.new()
	ogg_file.open(path, File.READ)
	var bytes = ogg_file.get_buffer(ogg_file.get_len())
	var stream = AudioStreamOGGVorbis.new()
	stream.data = bytes
	ogg_file.close()
	$AudioStreamPlayer.set_stream(stream)
	$AudioStreamPlayer.play(stream.get_length()/2)
func set_selected_map():
	if selected_map != GAME_C.map_selected.song_folder:
		map_changed = true
		selected_map = GAME_C.map_selected.song_folder
		clear_scores()
		add_map_leaderboard()
		
func _on_SongMenu_changed_selection():
		print("song set: ", GAME_C.map_selected.song_folder)
		selected_map = GAME_C.map_selected.song_folder
		print("song set-local: ", selected_map)
		print("selection_changed:")
	
func clear_scores():
	while leaderboard_cont.get_node("VBoxContainer").get_child_count() > 0 and map_changed == true:
		var child_size = leaderboard_cont.get_node("VBoxContainer").get_child_count()
		for i in child_size:
			leaderboard_cont.get_node("VBoxContainer").get_child(i).queue_free()
		map_changed = false
		
func add_map_leaderboard():
	var get_score
	for i in scores["response"] ["scores"].size():
		get_score = scores["response"] ["scores"] [i]
		add_leaderboard_list(get_score)
		
func add_list():
	for song in song_files:
		var item = list_item.instance()
		item.get_node("details/SongName").text = str(song.audio.title)
		item.get_node("details/Artist").text = str(song.audio.artist)
		item.get_node("details/Creator").text = str(song.creator)
		item.rect_min_size = Vector2(400, 110)
		scroll_cont.get_node("VBoxContainer").call_deferred("add_child", item)
		item.song = song

func free_leaderboatd_list():
	print(leaderboard_cont.get_node("VBoxContainer").get_child(0).get_name())
	
func add_leaderboard_list(data):
	var score = data.score
	var score_parse = {
		accuracy = null,
		combo = null,
		map = null,
		score = null
	}
	score = score.trim_prefix("{").trim_suffix("}")
	score = score.split(",")
	for i in score.size():
		var new = score[i].split(":")
		if new[0].strip_edges() == "accuracy":
			score_parse.accuracy = new[1]
		elif new[0].strip_edges() == "combo":
			score_parse.combo = new[1]
		elif new[0].strip_edges() == "map":
			score_parse.map = new[1]
		elif new[0].strip_edges() == "score":
			score_parse.score = new[1]
	if selected_map == score_parse.map:
		var item = list_leadboard_item.instance()
		item.get_node("score").text = str(score_parse.score + " (" + score_parse.combo + ")")
		item.get_node("Accuracy").text = str(score_parse.accuracy + "%")
		item.get_node("Player_name").text = str(data.guest)
		item.rect_min_size = Vector2(400, 70)
		leaderboard_cont.get_node("VBoxContainer").add_child(item)
	else:
		pass
		
func _on_GameJoltAPI_api_scores_fetched(data):
		set_scores(data)
		
func fetch_api():
	var api = get_node("GameJoltAPI")
	api.fetch_scores()
	
func set_scores(data):
	scores = JSON.parse(data).get_result()
	
func search_dir(dir_name):
	var file_names = []
	var dir = Directory.new()
	var _code = dir.open(dir_name)
	dir.list_dir_begin()
	
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			if file_name.ends_with(".json"):
				file_names.append([dir_name, file_name])
		elif file_name != ".." and file_name != ".":
			file_names += search_dir(dir_name + "/" + file_name)
		file_name = dir.get_next()
	return file_names

func parse_songs_dir():
	song_files = []
	var file_names = []
	var dir = Directory.new()

	var _code = dir.open(songs_dir)
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
	
func parse_song_files():
	song_files = []
	var file_names = []
	var dir = Directory.new()

	var _code = dir.open(songs_dir)

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
	var _song_file
	var _map_file
	
	for file_name_entry in file_names:
		song_file_dir = file_name_entry[0]
		song_file_name = file_name_entry[1]
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


func _on_back_btn_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://menu/MainMenu.tscn")
	
