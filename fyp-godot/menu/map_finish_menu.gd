extends Control

var score_values

onready var final_score_cont = get_node("score")
onready var final_combo_cont = get_node("combo")
onready var final_acc_cont = get_node("acc")

# Called when the node enters the scene tree for the first time.
func _ready():
	score_values = GAME_C.map_done_score
	
	final_score_cont.set_text(str(score_values.score))
	final_combo_cont.set_text(str(score_values.combo))
	final_acc_cont.set_text(str(score_values.accuracy))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
