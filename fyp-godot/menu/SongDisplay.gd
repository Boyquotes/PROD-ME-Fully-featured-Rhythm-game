extends Control

var song
onready var menu = get_tree().get_root().get_node("SongMenu")

func _on_Button_pressed():
	GAME_C.map_selected = song
	menu.set_selected_map()
	menu.play_song(song.audio_file)
	
func _input(event):
	if event is InputEventMouseButton and event.doubleclick:
# warning-ignore:return_value_discarded
		get_tree().change_scene("Game.tscn")
