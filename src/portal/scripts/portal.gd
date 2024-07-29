@tool

extends Node3D
class_name Portal 


const _PORTAL_CAMERA_NEAR_MIN = 0.01

var screen_shader : Shader = preload("res://shaders/portal_screen.gdshader")

@export var screen : Mesh:
	set(value):
		if value:
			for i in value.get_surface_count():
				var mat = ShaderMaterial.new()
				mat.shader = screen_shader
				mat.set_shader_parameter("VIEWPORT_TEXTURE", %Viewport.get_texture())
				value.surface_set_material(i, mat)
			%PortalMesh.mesh = value
			screen = value
		else:
			screen = null
		
@export var collision_shape : Shape3D:
	set(value):
		%Collider.shape = value
		collision_shape = value
		
@export var linked_portal : Portal
@export_range(_PORTAL_CAMERA_NEAR_MIN, 15, 0.01) var camera_near : float = 0.05
@export var main_camera : Camera3D
@export var turn_portal_with_camera : bool

@onready var linked_scale:Vector3 = Vector3.ONE
@onready var _screen_aabb = screen.get_aabb()
@onready var portal_mesh : MeshInstance3D = %PortalMesh
@onready var portal_camera : Camera3D = %PortalCamera
@onready var collider : CollisionShape3D = %Collider
@onready var viewport : SubViewport = %Viewport

var MAX_THICKNESS : float
var tracked_travellers : Array[Object]


func _ready():
	portal_mesh.global_transform = global_transform
	
	if not main_camera:
		main_camera = Global.player.CAMERA_CONTROLLER
		
	MAX_THICKNESS = viewport.size.x
	portal_camera.far = main_camera.far
	portal_camera.fov = main_camera.fov
	portal_camera.keep_aspect = main_camera.keep_aspect
	
	if not linked_portal:
		screen.material.set_shader_parameter("VIEWPORT_TEXTURE", Texture2D.new())
		set_process(false)
	

func _process(delta):
	if not Engine.is_editor_hint():
		if turn_portal_with_camera:
			global_rotation.y = main_camera.global_rotation.y
		portal_camera.global_transform = make_relative_to_linked(main_camera.global_transform)
		_update_camera_near()
		update_travellers(delta)
		_prevent_screen_clipping(Global.player.global_position)
		
		
func make_relative_to_linked(trans: Transform3D):
	var local:Transform3D = global_transform.affine_inverse() * trans
	var flipped:Transform3D = local.rotated(Vector3.UP, PI)
	var local_at_exit:Transform3D = linked_portal.global_transform * flipped
	return local_at_exit
	
	
func make_relative_direction(dir: Vector3):
	var local:Vector3 = global_transform.basis.inverse() * dir
	var flipped:Vector3 = local.rotated(Vector3.UP, PI)
	var local_at_exit:Vector3 = linked_portal.global_transform.basis * flipped
	return local_at_exit
		

func _update_camera_near():
	var corner_1:Vector3 = linked_portal.to_global(Vector3(_screen_aabb.position.x, _screen_aabb.position.y, 0) * linked_scale)
	var corner_2:Vector3 = linked_portal.to_global(Vector3(_screen_aabb.position.x + _screen_aabb.size.x, _screen_aabb.position.y, 0) * linked_scale)
	var corner_3:Vector3 = linked_portal.to_global(Vector3(_screen_aabb.position.x + _screen_aabb.size.x, _screen_aabb.position.y + _screen_aabb.size.y, 0) * linked_scale)
	var corner_4:Vector3 = linked_portal.to_global(Vector3(_screen_aabb.position.x, _screen_aabb.position.y + _screen_aabb.size.y, 0) * linked_scale)

	# Calculate the distance along the exit camera forward vector at which each of the portal corners projects
	var camera_forward:Vector3 = -portal_camera.global_transform.basis.z.normalized()

	var d_1:float = (corner_1 - portal_camera.global_position).dot(camera_forward)
	var d_2:float = (corner_2 - portal_camera.global_position).dot(camera_forward)
	var d_3:float = (corner_3 - portal_camera.global_position).dot(camera_forward)
	var d_4:float = (corner_4 - portal_camera.global_position).dot(camera_forward)
	
	portal_camera.near = max(_PORTAL_CAMERA_NEAR_MIN, min(d_1, d_2, d_3, d_4) - camera_near)
	
	
func _prevent_screen_clipping(view_point: Vector3) -> float:
	var half_height = main_camera.near * tan(deg_to_rad(main_camera.fov * 0.5))
	var half_width = half_height * (viewport.size.x / viewport.size.y)
	var thickness = Vector3(half_width, half_height, main_camera.near).length() + 0.5

	var screenT = portal_mesh.transform
	var is_facing_as_portal = (-global_basis.z).dot(global_position - view_point) > 0
	portal_mesh.transform.basis = Basis(screenT.basis.x, screenT.basis.y, Vector3(0, 0, thickness))
	portal_mesh.position = Vector3.FORWARD * thickness * (0.5 if (is_facing_as_portal) else -0.5)
	return thickness
	
	
func update_travellers(delta: float):
	for i in range(len(tracked_travellers)):
		var traveller = tracked_travellers[i] as Node3D
		
		var offset_from_portal = traveller.global_position - global_position
		var last_offset = traveller.get_meta("last_offset_from_portal")
			
		if not last_offset:
			traveller.set_meta("last_offset_from_portal", offset_from_portal)
			continue
			
		var portal_side = sign(offset_from_portal.dot(-global_basis.z)) 
		var portal_side_old = sign(last_offset.dot(-global_basis.z))
		
		if portal_side != portal_side_old:
			var pos = make_relative_to_linked(traveller.global_transform)
			var rot = make_relative_to_linked(main_camera.global_transform)
			teleport(traveller, pos.origin, rot.basis.get_euler(), delta)
			on_traveller_enter_portal(traveller)
			tracked_travellers.remove_at(i)
			i -= 1
		else:
			traveller.set_meta("last_offset_from_portal", offset_from_portal)
	
	
func on_traveller_enter_portal(traveller: Node3D):
	if not traveller in tracked_travellers:
		var offset_from_portal = traveller.global_position - global_position
		traveller.set_meta("last_offset_from_portal", offset_from_portal)
		tracked_travellers.append(traveller)
	
	
func teleport(body: Node3D, pos: Vector3, rot: Vector3, delta: float):
	body.global_transform = Transform3D(Basis.from_euler(rot), pos)
	
	if body is Player:
		body.set_mouse_rotation(rot, delta)
		body.WEAPON_CAMERA.global_transform = main_camera.global_transform
		
	linked_portal._prevent_screen_clipping(main_camera.global_position)
	body.set_velocity(make_relative_direction(body.get_velocity()))
	

func _on_collider_body_entered(body):
	print(body)
	if body.has_meta("last_offset_from_portal"):
		on_traveller_enter_portal(body)


func _on_collider_body_exited(body):
	if body in tracked_travellers:
		tracked_travellers.erase(body)
