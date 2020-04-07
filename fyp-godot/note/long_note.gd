extends "res://note/base_note.gd"
  
var note_len
var hold_started = false
var hold_end = false
var time_delay = 0.2
var time = 0;

func _on_ready():
	._on_ready()
	note_len = length*length_scale
	$note_beam.scale = Vector3(1,1,note_len)
			
func _on_process(delta):
	._on_process(delta)
	
	if gate == null or (gate.note_hit != null and gate.note_hit != self): 
		return
	#print("TESTING_NOTE = ", self, gate.note_hit)
	
	if is_colliding and not hold_end:
		if gate.is_hitting and not is_hit:
			hit()
			hold_started = true
			gate.note_hit = self
			#print("NOTE_HIT = ", self)
			#$MeshInstance.hide()
		elif !gate.is_hitting and hold_started and is_hit:
			hold_end = true
			gate.note_hit = null
			gate.is_hitting = false
			$note_beam.get_node("MeshInstance").hide()

	if hold_started and not hold_end:
		note_len -= speed.z * delta
		if note_len > 0:
			time += delta
			if time > time_delay:
				contHit()
				time = 0
				
func contHit():
	if ui != null:
		ui.hit_continued_feedback(accuracy)
		
func hit():
	$MeshInstance.hide()
	is_hit = true
	if ui != null:
		ui.hit_feedback(accuracy)
		ui.add_score()
