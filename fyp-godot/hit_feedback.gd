extends Node2D
	
func set_score(value):
	$AnimatedSprite.set_frame(value)
	$AnimationPlayer.play("appear")
