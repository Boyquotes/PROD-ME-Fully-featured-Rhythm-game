extends Control

var score_values

var user_name = SETTINGS._settings.player.player_name

onready var final_score_cont = get_node("score")
onready var final_combo_cont = get_node("combo")
onready var final_acc_cont = get_node("acc")

# Called when the node enters the scene tree for the first time.
func _ready():
	$Map_done.play()
	score_values = GAME_C.map_done_score
	var note_stats = GAME_C.note_stats
	var song_info = GAME_C.map_selected.audio
	var mapper_info = GAME_C.map_selected.creator
	
	final_score_cont.set_text(str(score_values.score))
	final_combo_cont.set_text(str(score_values.combo))
	final_acc_cont.set_text(str(score_values.accuracy) + "%")
	$"300x".set_text(str("x" + str(note_stats.hit_notes_perfect)))
	$"100x".set_text(str("x" + str(note_stats.hit_notes_great)))
	$"50x".set_text(str("x" + str(note_stats.hit_notes_ok)))
	$"missx".set_text(str("x" + str(note_stats.hit_notes_miss)))
	$beatmap.set_text(str(song_info.artist) + " - " + (song_info.title))
	$mapper.set_text(str("Map by: ", mapper_info))
	var date = OS.get_date()
	$"played by".set_text(str("Played by: ", user_name, " on " , ("%s-%02d-%02d" % [date.year, date.month, date.day])))
	
	api_add_score()
	
func api_add_score():
	var api = get_node("GameJoltAPI")
	api.add_score(score_values ,score_values.score, "","", str(user_name), 490800)
	
	


func _on_try_again_btn_pressed():
# warning-ignore:return_value_discarded
	$back.play()
	get_tree().change_scene("Game.tscn")


func _on_song_select_btn_pressed():
# warning-ignore:return_value_discarded
	$back.play()
	get_tree().change_scene("res://menu/SongMenu.tscn")


func _on_song_select_btn_mouse_entered():
	$hover.play()


func _on_try_again_btn_mouse_entered():
	$hover.play()
