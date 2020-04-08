extends Control

var not_paused = true

func _process(_delta):
	if Input.is_action_just_pressed("esc"):
		if not_paused:
			get_tree().paused = true
			not_paused = false
			visible = true
		else:
			get_tree().paused = false
			not_paused = true
			visible = false


func _on_Btn_resume_pressed():
	get_tree().paused = false
	not_paused = true

func _on_Btn_retry_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Game.tscn")
	get_tree().paused = false
	not_paused = true

func _on_Btn_quit_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://menu/MainMenu.tscn")
	get_tree().paused = false
	not_paused = true
