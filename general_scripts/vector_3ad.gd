extends Node


func face_at(node: Node3D, to: Vector3, use_model_front: bool = false, 
			 round_step : int = 3):
	var direction = (node.global_position - to).normalized()
	direction = round_by(direction, round_step)
	
	if direction != Vector3.UP and direction != Vector3.DOWN:
		node.look_at(to, Vector3.UP, use_model_front)
	elif use_model_front:
		node.rotation = direction.y * Vector3(1, 0, 0) * PI / 2
	else:
		node.rotation = direction.y * Vector3(-1, 0, 0) * PI / 2
		
		
func return_face_at(node: Node3D, to: Vector3, use_model_front: bool = false, 
			 		round_step : int = 3) -> Vector3:
	var old_rot = Vector3(node.rotation)
	var direction = (node.global_position - to).normalized()
	direction = round_by(direction, round_step)
	
	if direction != Vector3.UP and direction != Vector3.DOWN:
		node.look_at(to, Vector3.UP, use_model_front)
	elif use_model_front:
		node.rotation = direction.y * Vector3(1, 0, 0) * PI / 2
	else:
		node.rotation = direction.y * Vector3(-1, 0, 0) * PI / 2
		
	var new_rot = Vector3(node.rotation)
	node.rotation = old_rot
	
	return new_rot
	
	
func return_face_at_from_pos(node: Node3D, pos: Vector3, to: Vector3,
							 use_model_front: bool = false, 
			 				 round_step : int = 3) -> Vector3:
	var old_rot = Vector3(node.rotation)
	var direction = (pos - to).normalized()
	direction = round_by(direction, round_step)
	
	if direction != Vector3.UP and direction != Vector3.DOWN:
		node.look_at(to, Vector3.UP, use_model_front)
	elif use_model_front:
		node.rotation = direction.y * Vector3(1, 0, 0) * PI / 2
	else:
		node.rotation = direction.y * Vector3(-1, 0, 0) * PI / 2
		
	var new_rot = Vector3(node.rotation)
	node.rotation = old_rot
	
	return new_rot
	
		
func face_along(node: Node3D, direction: Vector3, use_model_front: bool = false, 
				round_step : int = 3):
	direction = round_by(direction, round_step)
	if direction != Vector3.UP and direction != Vector3.DOWN:
		node.look_at(node.global_position + direction, Vector3.UP, use_model_front)
	elif use_model_front:
		node.rotation = direction.y * Vector3(-1, 0, 0) * PI / 2
	else:
		node.rotation = direction.y * Vector3(1, 0, 0) * PI / 2
	


func cast_ray_from_camera(player_camera, distance: float = 1000, 
						  collision_mask = 0xFFFFFFFF,
						  from: Vector2 = get_viewport().size / 2) -> Dictionary:
	var space_state = player_camera.get_world_3d().direct_space_state
	var origin = player_camera.project_ray_origin(from)
	var vFront = player_camera.project_ray_normal(from)
	var end = origin + vFront * distance
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collision_mask = collision_mask
	
	var ray = space_state.intersect_ray(query)
	
	return ray
	
	
func snapped_by(vector: Vector3, step: int = 1):
	return vector.snapped(Vector3(step, step, step))
	
	
func round_by(vector: Vector3, step: int = 0):
	return (vector * 10 ** step).round() / 10 ** step
	
	
func squeze_vector(vec: Variant):
	if vec is Vector4:
		return Vector3(vec.x, vec.y, vec.z)
	elif vec is Vector3:
		return Vector2(vec.x, vec.y)
	else:
		push_error("Failed to squeze vector: ", vec)
		
		
func clamp_length(vec: Vector3, min_value: float, max_value: float):
	return vec.normalized() * clampf(vec.length(), min_value, max_value)
