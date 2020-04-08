extends Node

var map_selected =  null
var map_done_score

var player_name
var aproach_speed
var key1
var key2
var key3
var key4
var line1_color
var line2_color
var line3_color
var line4_color

func _ready():
	player_name = SETTINGS._settings.player.player_name
	aproach_speed = SETTINGS._settings.player.aproach_speed
	key1 = SETTINGS._settings.keybinds.key1
	key2 = SETTINGS._settings.keybinds.key2
	key3 = SETTINGS._settings.keybinds.key3
	key4 = SETTINGS._settings.keybinds.key4

