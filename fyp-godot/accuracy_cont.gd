extends Control

func hit_feedback(text):
	var score_notification = load("res://hit_feedback.tscn").instance()
	add_child(score_notification)
	score_notification.set_score(text)
	
