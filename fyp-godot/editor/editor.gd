extends Control

var ogg_file_path
var is_playing = false
var is_follow_playing = false
var window_size = 720
var stream = AudioStreamOGGVorbis.new()
var popup_active = false

var editor_dir
var audio_file_name = ""
var audio_load_thread = Thread.new()
var editor_thread = Thread.new()
var load_percent = 0
var audio_loaded = false

var map_start_pos = 0
var track_length
var track_speed
var track_tempo = 130
var map_info_was_saved = false
var pending_export = false

var waveform_length
var waveform_scale
var tempo_update_timeout = 0
var tempo_update_in_process = false

var ui_scale
var scale_ratio
var prev_scale_ratio

var bar_size
var bars_count
var quarter_time_in_sec
var sample_duration_in_sec

var window_scroll_size = 0
var pending_wscroll_update = false
var cursor_slider_pressed = false
var window_scroll_last_val = 0
var window_scroll_and_cursor_d = 0
var window_scroll_last_pos = 0

var tracks = []
var active_note
var active_track

onready  var map_info_dialog = get_node("Popup_cont/MapInfo")
onready  var load_audio_dialog = get_node("Popup_cont/loadAudio")
onready  var err_notice_dialog = get_node("Popup_cont/notice")
onready  var import_map_dialog = get_node("Popup_cont/ImportMap")

onready  var stream_player = get_node("AudioStreamPlayer")
onready  var visualizer_cont = get_node("CenterContainer/Visualizer")

onready  var load_audio_btn = get_node("MarginCont_file/file_btn_cont/import_btn")
onready  var tempo_btn = get_node("MarginCont_timers/bpm_input")
onready  var play_btn = get_node("MarginCont_play/play_btn_cont/play_btn")
onready  var scale_up_btn = get_node("MarginCont_zoom/ZoomBtn/HBoxContainer/ZoomInBtn")
onready  var scale_down_btn = get_node("MarginCont_zoom/ZoomBtn/HBoxContainer/ZoomOutBtn")
onready  var save_map_btn = get_node("MarginCont_file/file_btn_cont/save_btn")
onready  var import_map_btn = get_node("MarginCont_file/file_btn_cont/load_btn")

onready  var set_start_input = get_node("MarginCont_timers/start_pos_input")

onready  var waveform_c = get_node("ScrollContainer/VBoxContainer/Waveform")
onready  var waveform_n = waveform_c.get_node("AudioWaveform")
onready  var window_scroll = get_node("ScrollContainer")

onready  var cursor_c = get_node("ScrollContainer/VBoxContainer/Waveform/CursorControl")
onready  var cursor_static = cursor_c.get_node("CursorStatic")
onready  var cursor_playback = cursor_c.get_node("CursorPlayback")
onready  var cursor_slider = cursor_c.get_node("HSlider")

onready var loading_screen = get_node("OverlayLayer/LoadingScreen")

var track_scn = preload("res://editor/track.tscn")
onready  var tracks_c = get_node("ScrollContainer/VBoxContainer/TracksCont")

var editor_scn_path = "res://editor/editor.tscn"

#Setting up ready initialization on startup
func _ready():
	load_editor()
	
func load_editor():
	editor_thread.start(self, "build_editor", null, 1)

func build_editor(empty):
	load_percent += 100
	loading_screen.update_percent(load_percent)
	
	VisualServer.set_default_clear_color(EDITOR_C.BG_COLOR)
	
	set_process(true)
	set_process_input(true)
	
	window_scroll_size = window_scroll.get_minimum_size().x
	update_controls()
	setup_editor_dir()
	
	update_last_file_path(EDITOR_C.last_file_path)
	
func _process(delta):
	if pending_wscroll_update:
		window_scroll.set_h_scroll(window_scroll_size)
		pending_wscroll_update = false
	
	tracks_c.set_custom_minimum_size(Vector2(OS.get_window_size().x - 200, 100))
	cursor_c.set_position(Vector2(cursor_c.get_position().x, window_scroll.get_v_scroll()))
	
	if tempo_update_timeout > 0:
		tempo_update_timeout -= delta
	elif tempo_update_timeout < 0:
		tempo_update_timeout = 0
		tempo_update_in_process = true
		
		var old_waveform_length = waveform_length
		
		var cursor_val = cursor_slider.get_value()
		var scroll_val = window_scroll.get_h_scroll()
		var dd = scroll_val - cursor_val
	
		set_params()
		redraw_map()
		
		var scale = waveform_length / old_waveform_length
		cursor_slider.set_value(cursor_slider.get_value() * scale)
		window_scroll.set_h_scroll(cursor_slider.get_value() + dd)
		cursor_static.set_position(Vector2(cursor_slider.get_value(), cursor_static.get_position().y))
		tempo_update_in_process = false
		
	window_scroll_last_val = window_scroll.get_h_scroll()
	waveform_n.set_scroll(window_scroll_last_val)
	waveform_n.update()
	
	if is_playing:
		cursor_playback.set_position(Vector2(track_speed * stream_player.get_playback_position() * scale_ratio, 0))
	else :
		cursor_playback.set_position(cursor_static.get_position())
			
	if is_playing and is_follow_playing:
		if cursor_playback.get_position().x >= window_scroll.get_size().x * 0.5:
			window_scroll.set_h_scroll((int(cursor_playback.get_position().x) - int(window_scroll.get_size().x * 0.5)))
	
func update_last_file_path(file_path):
	EDITOR_C.last_file_path = file_path
	
#Setting up directories to be used by editor
func setup_editor_dir():
	print("user data dir:", OS.get_user_data_dir())
	editor_dir = "user://editor"
	var dir = Directory.new()
	
	if not dir.open(editor_dir) == OK:
		dir.make_dir(editor_dir)

	print("editor_dir:", editor_dir)
	
#setting any paramaters weather initial or dynamic
func set_params():
	sample_duration_in_sec = stream.get_length()
	quarter_time_in_sec = 60.0 / track_tempo
	bar_size = float(EDITOR_C.CELL_WIDTH * EDITOR_C.QUARTERS_COUNT * EDITOR_C.CELLS_IN_QUARTER_COUNT)
	
	track_speed = bar_size / (quarter_time_in_sec * EDITOR_C.QUARTERS_COUNT)
	track_length = round(track_speed * sample_duration_in_sec)
	bars_count = round(track_length / bar_size)
	
	waveform_scale = track_length / float(EDITOR_C.WAVEFORM_W)
	waveform_length = track_length
	
	print("track_speed:", track_speed)
	print("w scale:", waveform_scale)
	print("t len:", track_length)
	print("w len:", waveform_length)
	
	cursor_playback.speed = track_speed
	
	waveform_c.set_size(Vector2(waveform_length, EDITOR_C.WAVEFORM_H))
	
	waveform_n.set_full_size(waveform_c.get_size())
	waveform_n.set_viewport_rect(Rect2(Vector2(), Vector2(window_scroll.get_size().x, EDITOR_C.WAVEFORM_H)))
	waveform_n.set_custom_minimum_size(waveform_c.get_size())

	cursor_slider.set_max(waveform_length)
	cursor_slider.set_custom_minimum_size(Vector2(waveform_length, 16))
	
	ui_scale = 0
	scale_ratio = 1
	prev_scale_ratio = 1
	scale_to(0)

func load_waveform():
	waveform_n.set_stream(stream)
	

func play():
	if is_playing:
		is_playing = false
		visualizer_cont.hide()
		stream_player.stop()
	else :
		visualizer_cont.show()
		is_playing = true
		unset_active_note()
		unset_active_track()
		var t = cursor_slider.get_value() / track_speed
		t = t / scale_ratio
		stream_player.play(t)
		
	play_btn.set_playing(is_playing)

func cursor_focus():
	if is_playing:
		play()
		
	window_scroll.set_h_scroll(cursor_static.get_position().x - EDITOR_C.CURSOR_FOCUS_OFFSET)
	
func scale_to(dir):
	print("****** scale_to ******")
	
	if pending_wscroll_update:
		return 
	var value = dir * (waveform_scale / 10.0)
	ui_scale += value
	var curr_scale = waveform_scale + ui_scale
	scale_ratio = curr_scale / waveform_scale
	
	if scale_ratio <= 0 or str(scale_ratio) == "0":
		scale_ratio = 0.1
		ui_scale -= value
		print("scale_ratio:", scale_ratio)
		return 

	var scale_d = scale_ratio / prev_scale_ratio
		
	print("scale to:", dir)
	print("scale_ratio:", scale_ratio)
	print("scale_d:", scale_d)
	print("prev scale: ", prev_scale_ratio)
	print("ui_scale/curr_Scale: ", ui_scale/curr_scale)
	
	var cursor_val = cursor_slider.get_value()
	var scroll_val = window_scroll.get_h_scroll()
	var d = cursor_val - scroll_val
	cursor_slider.set_max(waveform_length * scale_ratio)
	cursor_slider.set_custom_minimum_size(Vector2(waveform_length * scale_ratio, 256))
	cursor_slider.set_value(cursor_val * scale_d)

	var scaled_size = Vector2(waveform_length * scale_ratio, EDITOR_C.WAVEFORM_H)

	waveform_c.set_custom_minimum_size(scaled_size)
	waveform_c.set_size(scaled_size)

	waveform_n.set_custom_minimum_size(scaled_size)
	waveform_n.set_size(scaled_size)

	waveform_n.set_full_size(scaled_size)
	waveform_n.set_scale_ratio(scale_ratio)

	cursor_playback.speed_scale = scale_ratio
	
	
	window_scroll_size = cursor_slider.get_value() - d
	pending_wscroll_update = true

	
	for t in tracks:
		t.update_scale(scale_ratio)
	
	prev_scale_ratio = scale_ratio

	print("scale updated!")

func _on_HSlider_value_changed(value):
	print("slider val changed:", value)
	
	if tempo_update_in_process:
		return 
		
	cursor_static.set_position(Vector2(value, cursor_static.get_position().y))
	
	if is_playing:
		var t = cursor_slider.get_value() / track_speed
		t = t / scale_ratio
		stream_player.play(t)
	
func _on_tempo_changed():
	print("_on_tempo_changed:")
	
	if track_tempo != tempo_btn.get_tempo():
		track_tempo = tempo_btn.get_tempo()
		tempo_update_timeout = 1.0
		print("tempo updated to", track_tempo)

func _on_ZoomBtn_down():
	scale_to( - 1)
	
func _on_ZoomBtn_up():
	scale_to(1)

func _input(e):
	if not audio_loaded:
		return 
	if e.is_action_pressed("editor_play") and popup_active == false:
		is_follow_playing = false
		play_btn.grab_focus()
		
		if e.is_action_pressed("editor_follow_play"):
			if not is_playing:
				is_follow_playing = true
	elif e.is_action_pressed("editor_scale_up"):
		scale_up_btn.grab_focus()
		scale_to(1)
	elif e.is_action_pressed("editor_scale_down"):
		scale_down_btn.grab_focus()
		scale_to( - 1)
	elif e.is_action_pressed("editor_cursor_focus"):
		cursor_focus()
		
func _on_ScrollContainer_minimum_size_changed():
	var d = cursor_slider.get_value() - window_scroll.get_h_scroll()
	
	if d > window_size and not pending_wscroll_update:
		window_scroll_size = window_scroll.get_h_scroll() + d
		pending_wscroll_update = true

func _on_ScrollContainer_resized():
	waveform_n.set_viewport_rect(Rect2(Vector2(window_scroll_last_val, 0), Vector2(window_scroll.get_size().x, EDITOR_C.WAVEFORM_H)))
	
func show_notice(text):
	err_notice_dialog.set_text(text)
	err_notice_dialog.set_as_minsize()
	err_notice_dialog.popup_centered()

func _on_import_btn_pressed():
	load_audio_dialog.set_current_path(EDITOR_C.last_file_path)
	load_audio_dialog.set_current_file("")
	load_audio_dialog.popup_centered()

func _on_loadAudio_file_selected(path):
	audio_load_thread.start(self, "load_audio", path)

#Checking if the file exists
func check_audio():
	var checker = File.new()
	
	if not checker.file_exists(ogg_file_path):
		show_notice(ogg_file_path + ("file not found"))
		return false
	return true

#checking if the audio data is loaded
func is_audio_loaded(audio_data):
	if audio_data == null:
		show_notice("error")
		audio_load_thread.wait_to_finish()
		return false
	else :
		return true

#loading the ogg audio
func load_ogg(path):
	var ogg_file = File.new()
	ogg_file.open(path, File.READ)
	var bytes = ogg_file.get_buffer(ogg_file.get_len())
	stream = AudioStreamOGGVorbis.new()
	stream.data = bytes
	ogg_file.close()
	return stream

#loading the selected file
func load_audio(input_file_path):
	print("loading started ", input_file_path)
	enable_load_audio(false)
	
	update_load_audio(tr("Loading."))

	var is_copied = copy_audio(input_file_path)
	if not is_copied:
		audio_load_thread.wait_to_finish()
		enable_load_audio(true)
		return 

	if not check_audio():
		audio_load_thread.wait_to_finish()
		enable_load_audio(true)
		return 
	
	update_load_audio(tr("Loading.."))
	stream = load_ogg(ogg_file_path)
	print("FILE:", ogg_file_path, stream)
	if not is_audio_loaded(stream):
		return 
	stream_player.set_stream(stream)
	update_load_audio(tr("Loading..."))

	load_waveform()
	set_params()
	
	audio_loaded = true
	update_controls()
	
	update_last_file_path(input_file_path)
	update_load_audio(tr("Audio Loaded"))
	audio_load_thread.wait_to_finish()
	print("audio loaded")
	
func update_controls():
	if audio_loaded:
		load_audio_btn.set_disabled(true)
		
		play_btn.set_disabled(false)
		import_map_btn.set_disabled(false)
		save_map_btn.set_disabled(false)
		scale_up_btn.set_disabled(false)
		scale_down_btn.set_disabled(false)
		tempo_btn.set_disabled(false)
		add_track()
		
		window_scroll.show()
	elif not audio_loaded:
		play_btn.set_disabled(true)
		import_map_btn.set_disabled(true)
		save_map_btn.set_disabled(true)
		scale_up_btn.set_disabled(true)
		scale_down_btn.set_disabled(true)
		tempo_btn.set_disabled(true)
		
		visualizer_cont.hide()
		window_scroll.hide()
		
func _on_play_btn_pressed():
	play()

func _on_AudioStreamPlayer_finished():
	if is_playing:
		play()
	
func update_cursor_length():
	var offset = 0
	for t in tracks:offset += t.get_custom_minimum_size().y
	cursor_static.set_length_offset(offset)
	cursor_playback.set_length_offset(offset)
	
func add_track():
	for i in 4:
		var t = track_scn.instance()
		t.set_info()
		t.setup(bars_count)
		t.set_position(Vector2(0, tracks.size() + 1 * (EDITOR_C.CELL_HEIGHT + EDITOR_C.TRACK_DISTANCE)))
		t.set_start_position(map_start_pos)
		tracks_c.call_deferred("add_child", t)
		tracks.append(t)
		set_active_track(t)
		update_cursor_length()
		scale_to(0)
	
func _on_start_pos_input_value_changed(value):
	map_start_pos = value
	for t in tracks:
		t.set_start_position(map_start_pos)

func set_active_track(track):
	print("SET ACTIVE:", track)
	if active_track != null:active_track.set_active(false)
	active_track = track
	active_track.set_active(true)

func unset_active_track():
	if active_track != null:active_track.set_active(false)
	active_track = null

func grab_cursor_slider_focus(e):
	return 
# warning-ignore:unreachable_code

func set_active_note(note):
	if active_note != null:active_note.set_active(false)
	active_note = note
	active_note.set_active(true)
	set_active_track(note.bar.track)

func unset_active_note():
	if active_note != null:active_note.set_active(false)
	active_note = null

func _on_editor_minimum_size_changed():
	pass

func redraw_map():
	for t in tracks:
		t.setup(bars_count, true)

func _on_MapInfo_map_info_saved():
	map_info_was_saved = true
	export_data()


func _on_save_btn_pressed():
	if not map_info_was_saved:
		map_info_dialog.popup_centered()
		pending_export = true

#Copying out audio file into a folder for backup purposes
func copy_audio(input_file_path):
	print("copy started")
	var file_name = input_file_path.get_file()
	var file_format = str(file_name.get_extension()).to_lower()
	var dir = Directory.new()
	audio_file_name = file_name.substr(0, file_name.find_last("."))
	ogg_file_path = editor_dir + "/" + "audio" + ".ogg"
	
	if file_format == "ogg":
		dir.copy(input_file_path, ogg_file_path)
	else :
		show_notice(str(file_format) + ("File not supported"))
		return false
	print("copy finished")
	return true

func export_data():
	var songs_dir = "songs"
	var song_file
	var song_folder
	var new_dir
	
	var dir = Directory.new()
	print("current dir: ", dir.get_current_dir())
	var code = dir.open(songs_dir)
	
	print("OPEN RETURN CODE: " + str(code))
	var rand_int
	randomize()
	rand_int = randi()
	song_folder = str(rand_int) + " " + map_info_dialog.audio_info.artist + "-" + map_info_dialog.audio_info.title 
	print(song_folder)
	dir.make_dir(song_folder)
	new_dir = songs_dir + "/" + song_folder
	dir.open(new_dir)
	
	var tracks_data = []
	for t in tracks:
		tracks_data.append(t.get_data())
	
	var data = {
		audio = map_info_dialog.audio_info, 
		creator = map_info_dialog.creator, 
		audio_file = map_info_dialog.audio_info.artist + "-" + map_info_dialog.audio_info.title + ".ogg",
		date = get_curr_date(), 
		tempo = track_tempo, 
		start_pos = map_start_pos * EDITOR_C.CELL_EXPORT_SCALE, 
		tracks = tracks_data, 
	}
	new_dir += "/" + "map-" + map_info_dialog.audio_info.artist + "-" + map_info_dialog.audio_info.title + ".json"
	Utils.write_json_file(new_dir, data)
	update_last_file_path(new_dir)
	new_dir = songs_dir + "/" + song_folder
	new_dir += "/" +map_info_dialog.audio_info.artist + "-" + map_info_dialog.audio_info.title + ".ogg"
	
	var file_name = "editor_dir/audio.ogg"
	var file_format = str(file_name.get_extension()).to_lower()
	ogg_file_path = editor_dir + "/" + "audio" + ".ogg"
	
	if file_format == "ogg":
		dir.copy(ogg_file_path, new_dir)
	else :
		show_notice(str(file_format) + ("File not found"))
		return false
		
	show_notice("Map Saved Successfully")
	print("copy finished")
	print("data exported")
	

func get_curr_date():
	var today = OS.get_date()
	return ("%s-%02d-%02d" % [today.year, today.month, today.day])


func _on_load_btn_pressed():
	import_map_dialog.set_current_path(EDITOR_C.last_file_path)
	import_map_dialog.set_current_file("")
	import_map_dialog.popup_centered()
	
func enable_load_audio(enabled):
	if enabled:
		load_audio_btn.set_text("Load Audio")
		load_audio_btn.set_disabled(false)
	else :
		load_audio_btn.set_text("Loading")
		load_audio_btn.set_disabled(true)
	
func update_load_audio(text):
	if load_audio_btn.is_disabled():
		load_audio_btn.set_text(text)
		
func _on_ImportMap_file_selected(path):
	import_data(path)

func import_data(path):
	var data = Utils.read_json_file(path)
	if not data:
		return
		
	track_tempo = int(data.tempo)
	tempo_btn.set_tempo(track_tempo)

	map_start_pos = int(int(data.start_pos) / EDITOR_C.CELL_EXPORT_SCALE)
	set_start_input.input.set_value(map_start_pos)

	map_info_dialog.set_data(data.creator, data.audio)
	map_info_was_saved = false
	pending_export = false

	clear_tracks()
	set_params()
	scale_to(0)
	
	var y = EDITOR_C.CELL_HEIGHT + EDITOR_C.TRACK_DISTANCE
	for track_data in data.tracks:
		var t = track_scn.instance()
		t.set_data(track_data)
		t.set_position(Vector2(0, y))
		t.set_start_position(map_start_pos)
		tracks_c.add_child(t)
		tracks.append(t)
		y += t.get_height()

	update_cursor_length()
	update_last_file_path(path)
	print("data imported")
	print("new track data:", tracks)

func destroy_track(track):
	if active_track == track:
		active_track = null
	tracks_c.remove_child(track)
	tracks.erase(track)
	update_cursor_length()
	
func clear_tracks():
	var tracksize = tracks.size()
	for t in tracksize:
		print("track ", t ," removed")
		print("track ", tracks[0] ," removed")
		destroy_track(tracks[0])


func _on_MapInfo_about_to_show():
	popup_active = true


func _on_MapInfo_popup_hide():
	popup_active = false
