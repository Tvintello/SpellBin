class_name ManaConduit extends StandardCurve3D


@export var texture : Texture2D = preload("res://assets/textures/drawings/mana_conduit.png")
@export var connect_texture : Texture2D = preload("res://assets/textures/drawings/conduit_connection.png")
@export var checker_body_class : GDScript = preload("res://src/drawings/mana_conduit/scripts/checker_body.gd")
@export var pixel_size : float = 0.01

const type : String = "spell_drawing"
const DEFAULT_COLOR : Color = Color(0, 0, 0)

var connection : MeshInstance3D
var first : Node3D  # with type spell_drawing\
var checker : CollisionShape3D
var checker_body : RigidBody3D
var ray_list := [RayCast3D.new(), RayCast3D.new(), 
				 RayCast3D.new(), RayCast3D.new(), 
				 RayCast3D.new(), RayCast3D.new()]
	
	
func set_color(color: Color):
	polygon.material.albedo_color = color
	
	if connection:
		connection.mesh.material.albedo_color = color
	

func reset_color() -> void:
	polygon.material.albedo_color = DEFAULT_COLOR
	
	if connection:
		connection.mesh.material.albedo_color = DEFAULT_COLOR
		
		
func add_color(color: Color) -> void:
	polygon.material.albedo_color += color
	
	if connection:
		connection.mesh.material.albedo_color += color
	
	
func enter(_pars: Dictionary):
	curve = Curve3D.new()
	curve.add_point(Vector3.ZERO)
		
	for ray in ray_list:
		add_child(ray)
	
	checker = CollisionShape3D.new()
	checker.shape = SphereShape3D.new()
	checker_body = checker_body_class.new()
	checker_body.add_child(checker)
	add_child(checker_body)
	
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = texture
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_HASH
	mat.uv1_scale = Vector3(1, 8, 1)
	var width = texture.get_width() * pixel_size
	create_rect_polygon(Vector2(width, 0.01), Vector2(-width / 2, 0), mat)
	
	
func update_position(pos: Vector3, normal: Vector3, ground_offset: float):
	pos = pos + normal * ground_offset
	var last = curve.point_count - 1
	var direction = Vector3.ZERO
	var angle : float
	
	if curve.point_count > 1:
		direction = curve.get_point_position(last) - curve.get_point_position(last - 1)
		var proj = Vector3(direction.x, 0, direction.z)
		var cross = proj.cross(Vector3.UP)
		var ve = Vector3Ad.round_by(checker_body.collision_normal.project(cross), 1)
		angle = ve.angle_to(Vector3.UP)
		print(ve, " ", angle, " ", cross)
	
	curve.set_point_tilt(last, angle)
		
	#var proj_dir = direction.project(Vector3(1, 0, 0)) + \
				   #direction.project(Vector3(0, 0, 1))
	#
	#var nor = (proj_dir.z * Vector3(1, 0, 0) - \
			   #proj_dir.dir.x * Vector3(0, 0, 1)).normalized()
	#
	#var point_basis := Basis(proj_dir, Vector3.UP, nor)
	#
	#for i in range(4):
		#var x = cos(PI * 2 * i / 4)
		#var y = sin(PI * 2 * i / 4)
		#var ray = ray_list[i]
		#ray.target_position = Vector3(x, y, 0) * point_basis
	#
	#ray_list[4].target_position = -proj_dir * point_basis
	#ray_list[5].target_position = proj_dir * point_basis
	
	if pos != curve.get_point_position(0):
		curve.set_point_position(last, pos)
		checker_body.global_position = pos
		set_color(DrawMode.ACCEPT_COLOR)
										
	var collider = Global.player.INTERACTION_RAY.get_collider()
	
	if _is_drawing(collider):
		var drawing = collider.get_parent()
		var min_entry = Vector3.INF
		
		for entry in drawing.entry_positions:
			var dis = entry + drawing.global_position - curve.get_point_position(last)
			
			if dis.length() < (min_entry - curve.get_point_position(last)).length():
				min_entry = entry + drawing.global_position
			
				
		if (pos != curve.get_point_position(0) or curve.point_count == 1) \
			and first != drawing:
			curve.set_point_position(last, min_entry)
			checker_body.global_position = min_entry
			if curve.point_count > 1:
				var r = collider.get_parent().get_radius() * collider.get_parent().pixel_size
				var vec = collider.global_position - curve.get_point_position(last - 1)
				vec = vec.length()
			
				if direction.length() > sqrt(vec**2 - r**2):
					set_color(DrawMode.REJECT_COLOR) # path intersects with circle
				else:
					set_color(DrawMode.ACCEPT_COLOR) # path doesn`t intersects with circle
		
	
func exit(ray: RayCast3D) -> bool:
	if ray.is_colliding():
		var collider = Global.player.INTERACTION_RAY.get_collider()
		var last = curve.point_count - 1
		var last_pos = curve.get_point_position(last)


		if _is_drawing(collider):
			if curve.point_count > 1:
				var r = collider.get_parent().get_radius() * collider.get_parent().pixel_size
				var vec = collider.global_position - curve.get_point_position(last - 1)
				vec = vec.length()
				var d = last_pos - curve.get_point_position(last - 1)
				d = d.length()
			
				if d <= sqrt(vec**2 - r**2):
					first.connected_drawings.append(collider.get_parent())
					collider.get_parent().connected_drawings.append(first)
					reset_color()
						
					# proper path connecting
					var connection = MeshInstance3D.new()
					connection.mesh = QuadMesh.new()
					var mat = StandardMaterial3D.new()
					mat.albedo_texture = connect_texture
					mat.albedo_color = polygon.material.albedo_color
					mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_HASH
					connection.mesh.material = mat	
					connection.mesh.size = Vector2(1, 1) * connect_texture.get_size().x * collider.get_parent().pixel_size
					collider.get_parent().add_child(connection)
					connection.translate_object_local((last_pos - collider.global_position) * collider.get_parent().transform.basis)
					var v = collider.global_position - last_pos
					var angle = v.angle_to(Vector3(-1, 0, 0))
					
					if -v.z > 0:
						connection.rotate_object_local(Vector3(0, 0, 1), PI / 2 - angle)
					else:
						connection.rotate_object_local(Vector3(0, 0, 1), PI / 2 + angle)	
						
					return false		
			else:
				first = collider.get_parent()
				curve.add_point(ray.get_collision_point())
			
				
		elif curve.point_count != 1:	
			curve.add_point(ray.get_collision_point())
			
	return true
			
			
func _is_drawing(collider: Variant):
	return collider and collider.get_parent().type == "spell_drawing"
	

func delete() -> void:
	queue_free()
	
