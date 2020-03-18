extends VBoxContainer

signal up
signal down

func _on_ZoomInBtn_pressed():
	emit_signal("up")

func _on_ZoomOutBtn_pressed():
	emit_signal("down")
