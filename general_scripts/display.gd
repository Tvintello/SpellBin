extends Node


func show_vector(node: Node, from: Vector3, to: Vector3 = Vector3.UP, one=false):
	# WARNING: This does not work for nodes except the world node yet
	# so vector_set can be only one
	
	var vector_set = node.get_node_or_null("VectorSet")
	if not vector_set:
		vector_set = Node3D.new()
		vector_set.name = "VectorSet"
		node.add_child(vector_set)
		
	var vector = Node3D.new()
	
	var cone = CylinderMesh.new()
	cone.top_radius = 0
	cone.bottom_radius = 0.05
	cone.height = 0.3
	var cone_instance = MeshInstance3D.new()
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(6, 0, 0)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	cone.material = mat
	cone_instance.mesh = cone
	vector.add_child(cone_instance)
	
	var dir = to - from
	if dir.normalized() != Vector3.UP and dir.normalized() != Vector3.DOWN and dir != cone_instance.position:
		cone_instance.look_at_from_position(cone_instance.global_position, dir)
		cone_instance.rotate_object_local(Vector3(1, 0, 0), -PI / 2)
		
	cone_instance.position = dir - dir.normalized() * 0.15 + from
	var path3d = StandardCurve3D.new()
		
	var path_mat = StandardMaterial3D.new()
	path_mat.albedo_color = Color(0, 2, 6)
	path_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	path3d.create_cylinder_polygon(0.02, 10, path_mat)
	vector.add_child(path3d)
	
	if one:
		if vector_set.get_child_count() != 0:
			var vec = vector_set.get_child(0)
			vec.remove_child(vec.get_child(0))
			vec.get_child(0).delete_curve()
			vector_set.remove_child(vector_set.get_child(0))

			
	vector_set.add_child(vector)
	path3d.create_line(from, to - dir.normalized() * (cone.height / 2))
	
	
func show_box(node: Node, size: Vector3, pos: Vector3):
	var box = BoxMesh.new()
	box.size = size
	var mat = ShaderMaterial.new()
	var shader = load("res://shaders/cel-shader-base.gdshader")
	mat.shader = shader
	box.surface_set_material(0, mat)
	var instance = MeshInstance3D.new()
	instance.mesh = box
	
	node.add_child(instance)
	instance.global_position = pos
		
		
func show_sphere(node: Node, pos: Vector3, radius: float, 
						rings: int = 4, radial_segments: int = 4):
	var sphere = SphereMesh.new()
	sphere.radius = radius
	sphere.rings = rings
	sphere.radial_segments = radial_segments
	sphere.height = radius * 2
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(4, 0, 0)
	sphere.surface_set_material(0, mat)
	var instance = MeshInstance3D.new()
	instance.mesh = sphere
	
	node.add_child(instance)
	instance.global_position = pos
		
		
func show_point(node: Node, pos: Vector3, radius: float = 0.05, 
				rings: int = 4, radial_segments: int = 4, 
				color: Color = Color(255, 0, 0)):
	var sphere = SphereMesh.new()
	sphere.radius = radius
	sphere.rings = rings
	sphere.radial_segments = radial_segments
	sphere.height = radius * 2
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	sphere.surface_set_material(0, mat)
	var instance = MeshInstance3D.new()
	instance.mesh = sphere
	
	node.add_child(instance)
	instance.global_position = pos

		
func create_label3d(node: Node, pos: Vector3, text: Variant, 
			   update: bool = false) -> Label3D:
	var label = Label3D.new()
	label.text = str(text)
	label.position = pos + Vector3.UP * (label.font_size / 2) / 100
	label.set_script(load("res://general_scripts/label3d.gd"))
	node.add_child(label)
	return label
		
