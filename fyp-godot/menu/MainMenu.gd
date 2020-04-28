extends Control

func _on_Play_btn_pressed():
# warning-ignore:return_value_discarded
	$button_click.play()
	get_tree().change_scene("res://menu/SongMenu.tscn")
	
func _on_Editor_btn_pressed():
# warning-ignore:return_value_discarded
	$button_click.play()
	get_tree().change_scene("res://editor/editor.tscn")

func _on_Exit_btn_pressed():
	get_tree().quit()
	
	
func _on_settings_btn_pressed():
	$settings/settings/AnimationPlayer.play("settings_tab")
	get_node("settings/settings").show()
	$button_click.play()

func _on_Play_btn_mouse_entered():
	$Menu_btns/Play_btn.set_scale(Vector2(1.1,1.1))
	$button_hover.play()

func _on_Play_btn_mouse_exited():
	$Menu_btns/Play_btn.set_scale(Vector2(1,1))

func _on_Editor_btn_mouse_entered():
	$Menu_btns/Editor_btn.set_scale(Vector2(1.1,1.1))
	$button_hover.play()

func _on_Editor_btn_mouse_exited():
	$Menu_btns/Editor_btn.set_scale(Vector2(1,1))

func _on_settings_btn_mouse_entered():
	$Menu_btns/settings_btn.set_scale(Vector2(1.1,1.1))
	$button_hover.play()

func _on_settings_btn_mouse_exited():
	$Menu_btns/settings_btn.set_scale(Vector2(1,1))

func _on_Exit_btn_mouse_entered():
		$Menu_btns/Exit_btn.set_scale(Vector2(1.1,1.1))
		$button_hover.play()

func _on_Exit_btn_mouse_exited():
		$Menu_btns/Exit_btn.set_scale(Vector2(1,1))

func _on_cancel_btn_pressed():
	$button_click.play()
