class_name InvokerSpellCircle extends SpellCircle


func create_spell_circle() -> void:
	var clone = %SpellCircleClone
	
	clone.mesh = mesh.duplicate()
	clone.mesh.flip_faces = true
	clone.global_rotation = global_rotation
	
	spell.transform.basis = transform.basis
	spell.create_spell()
	await get_tree().create_timer(1).timeout
	delete_circle()
	
