extends Control

var song
onready var menu = get_tree().get_root().get_node("SongMenu")

func _on_Button_pressed():
	$sound_hit.play()
	GAME_C.map_selected = song
	menu.set_selected_map()
	self.set_scale(Vector2(1.1,1.1))
	
func _input(event):
	if event is InputEventMouseButton and event.doubleclick:
# warning-ignore:return_value_discarded
		get_tree().change_scene("Game.tscn")


func _on_Button_focus_exited():
	self.set_scale(Vector2(1.0,1.0))
	$Sprite.modulate = Color("#E6C1A6")


func _on_Button_focus_entered():
	$Sprite.modulate = Color("#B1AED5")
	menu.play_song(song.audio_file)


func _on_Button_mouse_entered():
	self.set_scale(Vector2(1.05,1.05))
	$sound.play()


func _on_Button_mouse_exited():
	self.set_scale(Vector2(1,1))
