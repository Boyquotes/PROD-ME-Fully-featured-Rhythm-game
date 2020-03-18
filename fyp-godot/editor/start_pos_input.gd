extends Control

signal value_changed(value)

onready  var input = get_node("VBoxContainer/SpinBox")

func _on_SpinBox_value_changed(value):
	emit_signal("value_changed", value)
	print("Value changed:", value)
