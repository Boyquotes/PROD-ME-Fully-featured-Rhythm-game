extends Control

onready var score_cont = get_node("Score")
onready var combo_cont = get_node("combo")
onready var hit_feedback_cont = get_node("accuracy_cont")
onready var max_combo_cont = get_node("max_combo")

var score
var score_acc
var combo
var max_combo = 0


func _ready():
	reset()
	score_cont.set_text(str(score))
	combo_cont.set_text(str(combo))
	max_combo_cont.set_text(str(max_combo))
	
func _process(_delta):
	if combo > max_combo:
		max_combo = combo
	max_combo_cont.set_text(str(max_combo))
	score_cont.set_text(str(score))
	combo_cont.set_text(str(combo))
	
func reset():
	score = 0
	combo = 0

func add_score():
	score = score + (score_acc * combo)

func hit_feedback(accuracy):
	var text
	if accuracy == 1:
		text = "Perfect"
		score_acc = 300
		combo =combo + 1
		hit_feedback_cont.hit_feedback(text)
	elif accuracy == 2:
		text = "Great"
		score_acc = 100
		combo = combo + 1
		hit_feedback_cont.hit_feedback(text)
	elif accuracy == 3:
		text = "Ok"
		score_acc = 50
		combo =combo + 1
		hit_feedback_cont.hit_feedback(text)
	elif accuracy == 4:
		text = "Miss"
		score_acc = 0
		combo = 0
		hit_feedback_cont.hit_feedback(text)
