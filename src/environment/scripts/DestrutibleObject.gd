class_name DestructibleObject extends Node3D


@export var mesh_node: Node
@onready var aabb1 = mesh_node.get_aabb()
@onready var vec = preload("res://src/actors/player/scenes/raycast.tscn")


func _ready():
	if scale != Vector3(1, 1, 1):
		push_error("Scale must be Vector3(1, 1, 1)")
	mesh_node.mesh = update_mesh(mesh_node, position + Vector3(0, 0, 1), 0.5, 10, 10)

	
func cast_ray(origin, direction, distance,
			  space = get_world_3d().direct_space_state) -> Dictionary:
	var end = origin + direction * distance
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.hit_from_inside = true
	query.collide_with_bodies = true
	var result = space.intersect_ray(query)
	#Global.show_point(self, origin)
	return result


func update_mesh(mesh_instance: MeshInstance3D, sphere_pos: Vector3, radius: float, 
				 rings: int, radial_segments: int):
					
	#Global.show_hollow_sphere(self, sphere_pos, radius, rings, radial_segments)
	#mesh_instance.mesh.size *= mesh_instance.scale
	#mesh_instance.scale = Vector3(1, 1, 1)
					
	var arr_mesh = ArrayMesh.new()
	
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)

	# PackedVector**Arrays for mesh construction.
	var verts = PackedVector3Array()
	var inner_verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	
	var intersection_verts = []
	
	var scale = mesh_instance.scale
	
	# Vertex indices.
	var thisrow = 0
	var prevrow = 0
	var point = 0
	
	# Loop over rings.
	for row in range(rings + 1):
		var v = float(row) / rings
		var w = sin(PI * v)
		var y = cos(PI * v)

		# Loop over segments in ring.
		for col in range(radial_segments + 1):
			var u = float(col) / radial_segments
			var x = sin(u * PI * 2.0)
			var z = cos(u * PI * 2.0)
			var vert = Vector3(x * radius * w, y * radius, z * radius * w)

			# intersection detection
			var count = 1
			var face = PackedVector3Array([Vector3.ZERO, Vector3.ZERO, Vector3.ZERO])
			var intersection = false
			
			if row > 0 and col > 0:
				for a in mesh_instance.mesh.get_faces():
					face[count % 3] = a * scale
					if count % 3 == 0:
						var rUp = Geometry3D.segment_intersects_triangle(vert + sphere_pos - position, verts[(row - 1) * (rings + 1) + col] + sphere_pos - position, face[0], face[1], face[2])
						#Global.show_vector(self, vert + sphere_pos - position, verts[(row - 1) * (rings + 1) + col] + sphere_pos - position)
						if rUp:
							pass
							#if not verts[prevrow + col] in inner_verts:
								#pass
								##inner_verts.insert(prevrow + col, rUp)
							#else:
								#vert = rUp
								#intersection = true
							#Global.show_point(self, rUp + position)
							#
							#
						var rLeft = Geometry3D.segment_intersects_triangle(vert + sphere_pos - position, verts[row * (rings + 1) + col - 1] + sphere_pos - position, face[0], face[1], face[2])
						#Global.show_vector(self, vert + sphere_pos - position, verts[row * (rings + 1) + col - 1] + sphere_pos - position)
						if rLeft:
							pass
							#if not verts[thisrow + col - 1] in inner_verts:
								#inner_verts[thisrow + col - 1] = rUp
							#else:
								#vert = rLeft
								#intersection = true
#
							#Global.show_point(self, rLeft + position)
	
					count += 1
					
			verts.append(vert)
			
					
			if !is_inside_mesh(vert + sphere_pos - position, mesh_instance) or intersection:
				continue
				
			#Global.show_point(self, vert + sphere_pos)
			point += 1
			#______________________
			inner_verts.append(vert + sphere_pos - position) # МОЖЕТ ВОЗНИКНУТЬ ОШИБКА
			#_______________________
			normals.append(vert.normalized())
			uvs.append(Vector2(u, v))

			# Create triangles in ring using indices.
			if row > 0 and col > 0:
				# and len(intersection_verts) != 1 and intersection_verts[-1][1] != point
				# first triangle
				if verts[prevrow + col - 2] + sphere_pos - position in inner_verts and verts[prevrow + col - 1] + sphere_pos - position in inner_verts and verts[thisrow + col - 2] + sphere_pos - position in inner_verts:
					indices.append(prevrow + col - 1) # left top
					indices.append(prevrow + col) # top
					indices.append(thisrow + col - 1) # left
				else: 
					pass
				

				if verts[prevrow + col - 1] + sphere_pos - position in inner_verts and verts[thisrow + col - 1] + sphere_pos - position in inner_verts and verts[thisrow + col - 2] + sphere_pos - position in inner_verts:
					indices.append(prevrow + col) # top
					indices.append(thisrow + col) # current
					indices.append(thisrow + col - 1) # left
				else:
					pass
				
				
		prevrow = thisrow
		thisrow = point
			
	# Assign arrays to surface array.
	surface_array[Mesh.ARRAY_VERTEX] = inner_verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices

	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	
	return arr_mesh
	
	
func is_inside_mesh(point: Vector3, mesh_instance: MeshInstance3D) -> bool:
	# checking if point in bounding box
	var space = get_world_3d().direct_space_state
	var ab = mesh_instance.mesh.get_aabb()
	if !ab.has_point(point):
		return false
	var dir = Vector3(point).normalized()
	var diameter = sqrt(ab.get_shortest_axis_size() ** 2 
						+ ab.get_longest_axis_size() ** 2)
		
	var ray = cast_ray(point + position, dir, diameter, space)
	
	var hit_count = 0
	var refPoint = Vector3(point)
	while ray:
		if ray.get("collider_id") == mesh_instance.get_child(0).get_instance_id():
			hit_count += 1
		refPoint += dir
		ray = cast_ray(refPoint + mesh_instance.global_position, dir, diameter, space)
			
			
	if hit_count % 2 == 1 or hit_count == 0:
		return true
	else: 
		return false
		
