extends Control

onready var load_tween = get_node("LoadTween")

func update_percent(percent):
	load_tween.interpolate_property($ProgressBar, "value", $ProgressBar.value, percent, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	load_tween.start()
	
	yield(load_tween, "tween_completed")
	
	if percent == $ProgressBar.max_value:
		$AnimationPlayer.play("LoadingAnim")
		get_node(".").hide()
