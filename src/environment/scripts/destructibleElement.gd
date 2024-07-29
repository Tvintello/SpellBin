class_name destructibleElement extends MeshInstance3D


@export var material: Material
var has_collider: bool = true
@export var collider: CollisionShape3D:
	set(value):
		if value:
			collider = value
		else:
			has_collider = false


func _ready():
	if mesh is PlaneMesh:
		create_terrain_collider(mesh)
		mesh = warp_shape_box(0.2, position, position, mesh)
	elif mesh is SphereMesh:
		print("Sphere")
				
	if mesh:
		for i in mesh.get_surface_count():
			mesh.surface_set_material(i, material)
		
func create_terrain_collider(shape: Mesh) -> void:	
	var sh
	if has_collider:
		sh = HeightMapShape3D.new()
		sh.map_depth = shape.subdivide_depth + 2
		sh.map_width = shape.subdivide_width + 2
		collider.scale = Vector3(shape.size.x / (shape.subdivide_width + 2), 1, shape.size.y / (shape.subdivide_depth + 2))
		collider.shape = sh
		
		
func warp_shape_csg(radius: float, mesh: Mesh, Dpoint: Vector3, mesh_pos: Vector3, rings, radial_segments):
	pass
		
		
func warp_shape_box(radius: float, Dpoint: Vector3, mesh_pos: Vector3, mesh: Mesh):
	var arr_mesh = ArrayMesh.new()
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	
	# PackedVector**Arrays for mesh construction.
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	
	var i = 0
	var count = 1
	
	for vertex in mesh.get_faces():
		var arrays = mesh.surface_get_arrays(0)
		if (abs(vertex.z) > radius) or (abs(vertex.x) > radius):
			verts.append(vertex)
			#normals.append(arrays[2].slice((count - 1) * 3, count * 3))
			normals.append(vertex.normalized())
			uvs.append(Vector2(vertex.x, vertex.y))
			indices.append(i)
			
			i += 1
			
		count += 1
		
	
	# Assign arrays to surface array.
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices

	# Create mesh surface from mesh array.
	# No blendshapes, lods, or compression used.
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	return arr_mesh
		
	
func warp_shape(radius: float, mesh: Mesh, Dpoint: Vector3, mesh_pos: Vector3, rings, radial_segments) -> ArrayMesh:
	var arr_mesh = ArrayMesh.new()
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)

	# PackedVector**Arrays for mesh construction.
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	
	var b = 0
	
	# Vertex indices.
	var thisrow = 0
	var prevrow = 0
	var point = 0
	
	
	for vertex in mesh.get_faces():
		if Dpoint.distance_to(vertex + mesh_pos) > radius:
			verts.append(vertex)
			normals.append(vertex.normalized())
			uvs.append(Vector2(vertex.x, vertex.y))
			indices.append(b)
			
			b += 1
			
			var v = float(b) / rings
			var w = sin(PI * v)
			var y = cos(PI * v)
			
			if y + mesh_pos.y < Dpoint.y:

			# Loop over segments in ring.
				for j in range(radial_segments + 1):
					var u = float(j) / radial_segments
					var x = sin(u * PI * 2.0)
					var z = cos(u * PI * 2.0)
					var vert = Vector3(x * radius * w, y * radius, z * radius * w)
					verts.append(vert)
					normals.append(vert.normalized())
					uvs.append(Vector2(u, v))
					point += 1

					# Create triangles in ring using indices.
					if b > 0 and j > 0:
						# first triangle
						indices.append(prevrow + j - 1)
						indices.append(prevrow + j)
						indices.append(thisrow + j - 1)

						# second triangle
						indices.append(prevrow + j)
						indices.append(thisrow + j)
						indices.append(thisrow + j - 1)

		prevrow = thisrow
		thisrow = point
				

	# Assign arrays to surface array.
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices

	# Create mesh surface from mesh array.
	# No blendshapes, lods, or compression used.
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	return arr_mesh
	

func create_sphere_array(radius: float, radial_segments: int, 
		rings: int) -> Array:
			
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	var sh
	
	# Creating collider
	if has_collider:
		sh = SphereShape3D.new()
		sh.set_radius(radius)
		collider.shape = sh
	
	# PackedVector**Arrays for mesh construction.
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()

	# Vertex indices.
	var thisrow = 0
	var prevrow = 0
	var point = 0

	# Loop over rings.
	for i in range(rings + 1):
		var v = float(i) / rings
		var w = sin(PI * v)
		var y = cos(PI * v)

		# Loop over segments in ring.
		for j in range(radial_segments + 1):
			var u = float(j) / radial_segments
			var x = sin(u * PI * 2.0)
			var z = cos(u * PI * 2.0)
			var vert = Vector3(x * radius * w, y * radius, z * radius * w)
			verts.append(vert)
			normals.append(vert.normalized())
			uvs.append(Vector2(u, v))
			point += 1

			# Create triangles in ring using indices.
			if i > 0 and j > 0:
				# first triangle
				indices.append(prevrow + j - 1)
				indices.append(prevrow + j)
				indices.append(thisrow + j - 1)

				# second triangle
				indices.append(prevrow + j)
				indices.append(thisrow + j)
				indices.append(thisrow + j - 1)

		prevrow = thisrow
		thisrow = point
		
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	return surface_array
	
