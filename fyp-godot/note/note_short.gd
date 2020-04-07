extends "res://note/base_note.gd"

func _on_process(delta):
	._on_process(delta)
	
	if gate == null or (gate.note_hit != null and gate.note_hit != self): return
	
	if not is_hit:
		if is_colliding and gate.is_hitting:
				hit()
