extends Control


onready var button_cont = get_node("VBoxContainer")
onready var btn_script = load("res://menu/keyButton.gd")

var settings
var buttons = {}

func _ready():
	settings = SETTINGS._settings.duplicate()
	
	button_cont.get_node("player_cont/HBoxContainer/LineEdit").text = settings.player.player_name
	button_cont.get_node("player_cont/HBoxContainer2/SpinBox").value = settings.player.aproach_speed
		
	for key in settings.keybinds.keys():
		var hbox = HBoxContainer.new()
		var label = Label.new()
		var button = Button.new()
		
		hbox.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		button.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		
		label.text = key
		
		var value = settings.keybinds[key]
		button.text = OS.get_scancode_string(value)
		
		button.set_script(btn_script)
		button.key = key
		button.value = value
		button.menu = self
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		
		hbox.add_child(label)
		hbox.add_child(button)
		button_cont.get_node("keybind_cont").add_child(hbox)
		
		buttons[key] = button
		
	for key in settings.note_color.keys():
		var hbox = HBoxContainer.new()
		var label = Label.new()
		var color_picker = ColorPickerButton.new()
		
		hbox.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		color_picker.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		
		label.text = key
		
		var value = settings.note_color[key]
		
		color_picker.color = Color(value)
		
		hbox.add_child(label)
		hbox.add_child(color_picker)
		button_cont.get_node("notes_cont").add_child(hbox)

func change_settings(key, value):
	settings.keybinds[key] = value
	for k in settings.keybinds.keys():
		if k != key and value != null and settings.keybinds[k] == value:
			settings.keybinds[k] = null
			buttons[k].value = null
			buttons[k].text = "Unassigned"


func _on_cancel_btn_pressed():
	get_node(".").hide()


func _on_save_btn_pressed():
	pass # Replace with function body.
