extends VBoxContainer

signal up
signal down


func _on_up_pressed():
	emit_signal("up")


func _on_down_pressed():
	emit_signal("down")
