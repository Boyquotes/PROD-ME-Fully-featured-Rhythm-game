extends Control

var ogg_file_path
var is_playing = false
var is_follow_playing = false
var window_size = 950
var stream = AudioStreamOGGVorbis.new()

var editor_dir
var audio_file_name = ""
var audio_load_thread = Thread.new()
var audio_loaded = false

var sample_duration_in_sec
var track_length
var track_speed
var track_tempo = 130

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

var window_scroll_size = 0
var pending_wscroll_update = false
var cursor_slider_pressed = false
var window_scroll_last_val = 0
var window_scroll_and_cursor_d = 0
var window_scroll_last_pos = 0

onready  var load_audio_dialog = get_node("Popup_cont/loadAudio")
onready var err_notice_dialog = get_node("Popup_cont/notice")

onready  var stream_player = get_node("AudioStreamPlayer")

onready  var load_audio_btn = get_node("MarginCont_file/file_btn_cont/import_btn")
onready  var tempo_btn = get_node("MarginCont_timers/bpm_input")
onready  var play_btn = get_node("MarginCont_play/play_btn_cont/play_btn")
onready  var scale_up_btn = get_node("MarginCont_zoom/ZoomBtn/HBoxContainer/ZoomInBtn")
onready  var scale_down_btn = get_node("MarginCont_zoom/ZoomBtn/HBoxContainer/ZoomOutBtn")
onready  var waveform_c = get_node("ScrollContainer/VBoxContainer/Waveform")
onready  var waveform_n = waveform_c.get_node("AudioWaveform")
onready  var window_scroll = get_node("ScrollContainer")

onready  var cursor_c = get_node("ScrollContainer/VBoxContainer/Waveform/CursorControl")
onready  var cursor_static = cursor_c.get_node("CursorStatic")
onready  var cursor_playback = cursor_c.get_node("CursorPlayback")
onready  var cursor_slider = cursor_c.get_node("HSlider")

#Setting up ready initialization on startup
func _ready():
	VisualServer.set_default_clear_color(EDITOR_C.BG_COLOR)
	get_tree().set_auto_accept_quit(false)
	
	set_process(true)
	set_process_input(true)
	
	window_scroll_size = window_scroll.get_minimum_size().x
	update_controls()
	setup_editor_dir()

func _process(delta):
	if pending_wscroll_update:
		window_scroll.set_h_scroll(window_scroll_size)
		pending_wscroll_update = false
	
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
	
#Update last known file path
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
	
	waveform_c.set_size(Vector2(waveform_length, EDITOR_C.WAVEFORM_H))
	waveform_n.set_full_size(waveform_c.get_size())
	waveform_n.set_viewport_rect(Rect2(Vector2(), Vector2(window_scroll.get_size().x, EDITOR_C.WAVEFORM_H)))
	waveform_n.set_custom_minimum_size(waveform_c.get_size())
	
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

#Show any ok notices
func show_notice(_text):
	err_notice_dialog.set_text("error")
	err_notice_dialog.popup()

#New button listener
func _on_import_btn_pressed():
	load_audio_dialog.set_current_path(EDITOR_C.last_file_path)
	load_audio_dialog.set_current_file("")
	load_audio_dialog.popup()

#Listener for selecting the audio file
func _on_loadAudio_file_selected(path):
	audio_load_thread.start(self, "load_audio", path)

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

	var is_copied = copy_audio(input_file_path)
	if not is_copied:
		audio_load_thread.wait_to_finish()
		return 

	if not check_audio():
		audio_load_thread.wait_to_finish()
		return 

	stream = load_ogg(ogg_file_path)
	print("FILE:", ogg_file_path, stream)
	if not is_audio_loaded(stream):return 
	stream_player.set_stream(stream)

	load_waveform(stream)
	set_params()

	audio_loaded = true
	update_controls()
	
	audio_load_thread.wait_to_finish()
	update_last_file_path(input_file_path)
	
	print("audio loaded")
	
func update_controls():
	if audio_loaded:
		load_audio_btn.set_disabled(true)
		play_btn.set_disabled(false)
		scale_up_btn.set_disabled(false)
		scale_down_btn.set_disabled(false)
		tempo_btn.set_disabled(false)
		window_scroll.show()
	elif not audio_loaded:
		load_audio_btn.set_disabled(false)
		play_btn.set_disabled(true)
		scale_up_btn.set_disabled(true)
		scale_down_btn.set_disabled(true)
		tempo_btn.set_disabled(true)
		
		window_scroll.hide()
		
func play():
	if is_playing:
		is_playing = false
		stream_player.stop()
	else :
		is_playing = true
		var t = cursor_slider.get_value() / track_speed
		t = t / scale_ratio
		stream_player.play()
		
	play_btn.set_playing(is_playing)


func _on_play_btn_pressed():
	play()
	
func load_waveform(stream):
	waveform_n.set_stream(stream)
	
func _on_HSlider_value_changed(value):
	print("slider val changed:", value)

func _on_tempo_changed():
	print("_on_tempo_changed:")
	
	if track_tempo != tempo_btn.get_tempo():
		track_tempo = tempo_btn.get_tempo()
		tempo_update_timeout = 1.0
		print("tempo updated to", track_tempo)


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
	
	prev_scale_ratio = scale_ratio

	print("scale updated!")
	
func _on_ZoomBtn_down():
	scale_to( - 1)
	
func _on_ZoomBtn_up():
	scale_to(1)

func _on_editor_minimum_size_changed():
	pass

func _input(e):
	if not audio_loaded:return 
	if e.is_action_pressed("editor_play"):
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
		
func _on_ScrollContainer_minimum_size_changed():
	var d = cursor_slider.get_value() - window_scroll.get_h_scroll()
	
	if d > window_size and not pending_wscroll_update:
		window_scroll_size = window_scroll.get_h_scroll() + d
		pending_wscroll_update = true

func _on_ScrollContainer_resized():
	waveform_n.set_viewport_rect(Rect2(Vector2(window_scroll_last_val, 0), Vector2(window_scroll.get_size().x, EDITOR_C.WAVEFORM_H)))
