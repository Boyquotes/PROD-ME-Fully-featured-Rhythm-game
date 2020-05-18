extends "res://note/base_note.gd"
  
var note_len
var hold_started = false
var hold_end = false
var time_delay = 0.1
var time = 0
var hold = 0
var note_hitting = false

func _on_ready():
	._on_ready()
	note_len = length*length_scale
	$note_beam.scale = Vector3(1,1,note_len)

func _exit_tree():
	if hold_end or hold_started:
		hold_anims(false)
		
func _on_process(delta):
	if is_colliding and not hold_end:
		if gate.is_hitting and not is_hit:
			hit()
			hold_started = true
			gate.note_hit = self
		elif !gate.is_hitting and hold_started and is_hit:
			hold_end = true
			gate.note_hit = null
			gate.is_hitting = false
			$note_beam.get_node("MeshInstance").hide()
			hold_anims(false)
			
	if hold_started and not hold_end:
		note_len -= speed.z * delta
		note_hitting = true
		if note_hitting == true and note_len > 0:
			print (note_len)
			hold_anims(true)
			time += delta
			if time > time_delay:
				contHit()
				time = 0
		else:
			print("anim stop", gate)
			note_hitting = false
			hold_anims(false)
		
func hold_anims(play):
	if play == true:
		gate.get_node("Animations/long_hit_hold").visible = true
		gate.get_node("Animations/long_hit_hold").play()
	else:
		gate.get_node("Animations/long_hit_hold").visible = false
		gate.get_node("Animations/long_hit_hold").stop()
		
func contHit():
	ui.hit_continued_feedback(accuracy)
	
func hit(is_miss = false):
	$MeshInstance.hide()
	is_hit = true
	if is_miss and $note_beam != null:
		$note_beam/MeshInstance.hide()
	ui.hit_feedback(accuracy)
	ui.add_score()
