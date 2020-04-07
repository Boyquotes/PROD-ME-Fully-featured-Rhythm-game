extends Control

var song

func _on_Button_pressed():
	GAME_C.map_selected = song
	get_tree().change_scene("res://Game.tscn")
