extends "res://note/base_note.gd"
  
var note_len
var hold_started = false
var hold_end = false

func _on_ready():
	._on_ready()
	note_len = length*length_scale
	$note_beam.scale = Vector3(1,1,note_len)
	print(note_len)
			
func _on_process(delta):
	._on_process(delta)
	
	if not is_hit:
		if is_colliding and gate and not hold_end:
			if gate.is_hitting:
				hold_started = true
				$MeshInstance.hide()
			elif hold_started:
				hold_end = true

		if hold_started and not hold_end:
			note_len -= speed.z * delta
			if note_len <= 0:
				hit()
			else:
				$note_beam.scale = Vector3(1,1,note_len)
				translate(-speed*delta)
				multiplier = 1
					
