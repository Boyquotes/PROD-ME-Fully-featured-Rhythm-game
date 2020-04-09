extends Control

func _ready():
	pass
func _on_Play_btn_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://menu/SongMenu.tscn")
	
func _on_Editor_btn_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://editor/editor.tscn")


func _on_Exit_btn_pressed():
	get_tree().quit()


func _on_settings_btn_pressed():
	$settings/settings/AnimationPlayer.play("settings_tab")
	get_node("settings/settings").show()
