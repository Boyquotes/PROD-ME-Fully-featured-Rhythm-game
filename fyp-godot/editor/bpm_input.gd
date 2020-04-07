extends Control

signal tempo_changed

var tempo_meter_time = 0
var tempo_meter_started = false
var tempo_meter_values = []

onready  var tempo_value_input = get_node("VBoxContainer/HBoxContainer/SpinBox")
onready  var btn = get_node("VBoxContainer/HBoxContainer/btn_tap")

func _ready():
	set_process(true)

func _process(delta):
	if tempo_meter_started:
		tempo_meter_time += delta
		
		if tempo_meter_time > 1.5:
			tempo_meter_started = false

func _on_meter_btn_pressed():
	if not tempo_meter_started:
		tempo_meter_started = true
		tempo_meter_time = 0
		tempo_meter_values = []
	else :
		var value = round(60.0 / tempo_meter_time)
		tempo_meter_values.append(value)
		if tempo_meter_values.size() > 10:tempo_meter_values.pop_front()
		print(tempo_meter_values)

		var sum = 0.0
		for v in tempo_meter_values:sum += v
		var tempo = round(sum / tempo_meter_values.size())

		tempo_value_input.set_value(tempo)
		tempo_meter_time = 0

func _on_SpinBox_value_changed(_value):
	emit_signal("tempo_changed")

func set_disabled(value):
	tempo_value_input.set_editable( not value)
	btn.set_disabled(value)

func get_tempo():
	return tempo_value_input.get_value()

func set_tempo(value):
	tempo_value_input.set_value(float(value))
