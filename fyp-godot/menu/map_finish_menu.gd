extends Control

var score_values

var user_name = GAME_C.player_name

onready var final_score_cont = get_node("score")
onready var final_combo_cont = get_node("combo")
onready var final_acc_cont = get_node("acc")

# Called when the node enters the scene tree for the first time.
func _ready():
	score_values = GAME_C.map_done_score
	
	final_score_cont.set_text(str(score_values.score))
	final_combo_cont.set_text(str(score_values.combo))
	final_acc_cont.set_text(str(score_values.accuracy))
	
	api_add_score()
	
func api_add_score():
	var api = get_node("GameJoltAPI")
	api.add_score(score_values ,score_values.score, "","", str(user_name), 490800)
	
	


func _on_try_again_btn_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("Game.tscn")


func _on_main_btn_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://menu/MainMenu.tscn")


func _on_song_select_btn_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://menu/SongMenu.tscn")
