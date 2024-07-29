class_name InteractableObject extends RigidBody3D


var mesh_node: Node
var collider : CollisionShape3D
var particles : GPUParticles3D


func _ready():
	mesh_node = find_children("*", "MeshInstance3D", true)[0]
	collider = find_children("*", "CollisionShape3D", true)[0]
	particles = find_children("*", "GPUParticles3D", true)[0]
	
	
func get_velocity() -> Vector3:
	return linear_velocity
	
	
func set_velocity(value: Vector3) -> void:
	linear_velocity = value
	

func create_glowing(offset: float = 1.2) -> void:
	particles.emitting = true
	for surf in range(mesh_node.mesh.get_surface_count()):
		var mesh_material = mesh_node.mesh.surface_get_material(surf)
		if mesh_material:
			while mesh_material:
				if mesh_material.next_pass:
					mesh_material = mesh_material.next_pass
				else:
					break
			var mat2 = StandardMaterial3D.new()
			mat2.albedo_color = Color(36, 91, 255)
			mat2.cull_mode = BaseMaterial3D.CULL_FRONT
			mat2.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			mat2.grow = true
			mat2.grow_amount = 0.05
			
			var mat3 = StandardMaterial3D.new()
			mat3.albedo_color = Color(0.16, 0.4, 1.1, 0.4)
			mat3.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat2.next_pass = mat3
			mesh_material.next_pass = mat2
			
		else:
			var mat1 = StandardMaterial3D.new()
			var mat2 = StandardMaterial3D.new()
			
			mat2.albedo_color = Color(36, 91, 255)
			mat2.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			mat2.cull_mode = BaseMaterial3D.CULL_FRONT
			mat2.grow = true
			mat2.grow_amount = 0.05
			
			var mat3 = StandardMaterial3D.new()
			mat3.albedo_color = Color(0.16, 0.4, 1.1, 0.4)
			mat3.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			
			mat2.next_pass = mat3
			mat1.next_pass = mat2
			mesh_material = mat1
	
	
func remove_glowing():
	particles.emitting = false
	for surf in range(mesh_node.mesh.get_surface_count()):
		mesh_node.mesh.surface_get_material(surf).next_pass = null
	
	

