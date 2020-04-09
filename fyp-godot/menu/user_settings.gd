extends Node

const SAVE_PATH = "res://user/config.cfg"

var _config_file = ConfigFile.new()
var _settings = {
	"player":{
		"player_name": null,
		"aproach_speed": null,
		},
	"keybinds":{
		"key1": null,
		"key2": null,
		"key3": null,
		"key4": null
		},
	"note_color":{
			"line1": null,
			"line2": null,
			"line3": null,
			"line4": null
		}
	}
	
func _ready():
	load_settings()
	set_game_binds()
	
func save_settings():
	for section in _settings.keys():
		for key in _settings[section]:
			_config_file.set_value(section, key, _settings[section][key])
	_config_file.save(SAVE_PATH)

func load_settings():
	var error = _config_file.load(SAVE_PATH)
	if error != OK:
		return
	for section in _settings.keys():
		for key in _settings[section]:
			_settings[section][key] = _config_file.get_value(section, key, null)

func set_game_binds():
	for key in _settings.keybinds:
		var value = _settings.keybinds[key]
		var actionlist = InputMap.get_action_list(key)
		if !actionlist.empty():
			InputMap.action_erase_event(key, actionlist[0])
		
		var new_key = InputEventKey.new()
		new_key.set_scancode(value)
		InputMap.action_add_event(key, new_key)
