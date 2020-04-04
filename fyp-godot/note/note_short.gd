extends "res://note/base_note.gd"

func _on_process(delta):
	._on_process(delta)
	
	if not is_hit:
		if is_colliding and gate:
			if gate.is_hitting:
				hit()
