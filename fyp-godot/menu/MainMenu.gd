extends Control

func _ready():
	pass
func _on_Play_btn_pressed():
	get_tree().change_scene("res://menu/SongMenu.tscn")
	
func _on_Editor_btn_pressed():
	get_tree().change_scene("res://editor/editor.tscn")
