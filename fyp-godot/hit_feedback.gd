extends Node2D
	
func set_score(value):
	$Label.text = value
	
func get_score() -> int:
	return int($Label.text.center(1))
