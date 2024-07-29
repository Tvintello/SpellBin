@tool

class_name WeaponController extends Node3D


@export var sway_noise : NoiseTexture2D
@export var WEAPON_TYPE : Weapons:
	set(value):
		WEAPON_TYPE = value
		if Engine.is_editor_hint():
			sway_noise.noise = FastNoiseLite.new()	
			await sway_noise.changed
			load_weapon()
			
@export var sway_speed : float = 1.2
@export var reset : bool = false:
	set(value):
		reset = value
		if Engine.is_editor_hint():
			sway_noise.noise = FastNoiseLite.new()	
			await sway_noise.changed
			load_weapon()
			
@export var MAX_TELEKINESIS_VELOCITIY : float = 100
@export var disabled : bool = false

@onready var weapon_mesh : MeshInstance3D = %WeaponMesh
@onready var weapon_shadow : MeshInstance3D = %WeaponShadow
@onready var tip : Marker3D = %Tip
@onready var telekinesis_object : Node = null
@onready var telekinesis_power : int = 16
@onready var telekinesis_radius : float
@onready var telekinesis_curve : StandardCurve3D
@onready var telekinesis_distance : float = 20
@onready var attack_timer : Timer = %AttackTimer
@onready var circle_scene : PackedScene = preload("res://src/drawings/magic_circle/scenes/invoker_spell_circle.tscn")

var mouse_movement : Vector2
var random_sway_x
var random_sway_y
var random_sway_amount : float
var time : float = 0.0
var idle_sway_adjustment
var idle_sway_rotation_strength
var weapon_bob_amount : Vector2 = Vector2.ZERO
var raycast_test = preload("res://src/actors/player/scenes/raycast.tscn")
var prev_televel : Vector3 = Vector3.ZERO
var attack_cooldown : float
var drawing : bool = false


func _ready() -> void:
	attack_timer.one_shot = true
	
	if not sway_noise:
		sway_noise = NoiseTexture2D.new()
	sway_noise.noise = FastNoiseLite.new()	
	await sway_noise.changed
	load_weapon()
	
	if not Engine.is_editor_hint():
		telekinesis_curve = StandardCurve3D.new()
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(36, 91, 255)
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		telekinesis_curve.create_cylinder_polygon(0.02, 10, mat)
		get_tree().root.get_child(1).add_child(telekinesis_curve)
	
	
func _input(event):
	if event.is_action_pressed("item1"):
		WEAPON_TYPE = load("res://scene_objects/weapons/wand/wand.tres")
		load_weapon()
		
	if event.is_action_pressed("item2"):
		WEAPON_TYPE = load("res://scene_objects/weapons/wand/wandLeft.res")
		load_weapon()
		
	if event is InputEventMouseMotion:
		mouse_movement = event.relative
	
	
func load_weapon() -> void:
	weapon_mesh.mesh = WEAPON_TYPE.mesh
	position = WEAPON_TYPE.position
	rotation_degrees = WEAPON_TYPE.rotation
	scale = WEAPON_TYPE.scale
	weapon_shadow.visible = WEAPON_TYPE.shadow
	idle_sway_adjustment = WEAPON_TYPE.idle_sway_adjustment
	idle_sway_rotation_strength = WEAPON_TYPE.idle_sway_rotation_strength
	random_sway_amount = WEAPON_TYPE.random_sway_amount
	attack_cooldown = WEAPON_TYPE.attack_cooldown
	
	
func update_weapon() -> void:
	rotation_degrees = WEAPON_TYPE.rotation
	

func sway_weapon(delta: float, isIdle: bool) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_movement = mouse_movement.clamp(WEAPON_TYPE.sway_min, WEAPON_TYPE.sway_max)
	else:
		mouse_movement = Vector2(0, 0)
	
	if isIdle:
		var sway_random : float = get_sway_noise()
		var sway_random_adjusted : float = sway_random * idle_sway_adjustment
		
		time += delta * (sway_speed + sway_random)
		random_sway_x = sin(time * 1.5 * sway_random_adjusted) / random_sway_amount
		random_sway_y = sin(time - sway_random_adjusted) / random_sway_amount

		position.x = lerp(position.x, WEAPON_TYPE.position.x - (mouse_movement.x * \
			WEAPON_TYPE.sway_amount_position + random_sway_x) * delta, WEAPON_TYPE.sway_speed_position)
		position.y = lerp(position.y, WEAPON_TYPE.position.y - (mouse_movement.y * \
			WEAPON_TYPE.sway_amount_position + random_sway_y) * delta, WEAPON_TYPE.sway_speed_position)	
			
		rotation_degrees.y = lerp(rotation_degrees.y, WEAPON_TYPE.rotation.y - (mouse_movement.x * \
			WEAPON_TYPE.sway_amount_rotation + random_sway_y * idle_sway_rotation_strength)\
			 * delta, WEAPON_TYPE.sway_speed_rotation)
		rotation_degrees.x = lerp(rotation_degrees.y, WEAPON_TYPE.rotation.y - (mouse_movement.x * \
			WEAPON_TYPE.sway_amount_rotation + random_sway_x * idle_sway_rotation_strength)\
			 * delta, WEAPON_TYPE.sway_speed_rotation)
			
	else:
		position.x = lerp(position.x, WEAPON_TYPE.position.x - (mouse_movement.x * \
			WEAPON_TYPE.sway_amount_position + weapon_bob_amount.x) * delta, WEAPON_TYPE.sway_speed_position)
		position.y = lerp(position.y, WEAPON_TYPE.position.y - (mouse_movement.y * \
			WEAPON_TYPE.sway_amount_position + weapon_bob_amount.y) * delta, WEAPON_TYPE.sway_speed_position)	
			
		rotation_degrees.y = lerp(rotation_degrees.y, WEAPON_TYPE.rotation.y - (mouse_movement.x * \
			WEAPON_TYPE.sway_amount_rotation) * delta, WEAPON_TYPE.sway_speed_rotation)
		rotation_degrees.x = lerp(rotation_degrees.y, WEAPON_TYPE.rotation.y - (mouse_movement.x * \
			WEAPON_TYPE.sway_amount_rotation) * delta, WEAPON_TYPE.sway_speed_rotation)
			

func weapon_bob(delta: float, speed: float, hor_amount: float, ver_amount: float) -> void:
	time += delta
	
	weapon_bob_amount.x = sin(time * speed) * hor_amount
	weapon_bob_amount.y = abs(cos(time * speed) * ver_amount)
	
		
func get_sway_noise():
	var player_position : Vector3 = Vector3.ZERO
	
	if not Engine.is_editor_hint():
		player_position = Global.player.global_position
		
	var noise_location : float = sway_noise.noise.get_noise_2d(player_position.x, player_position.y)
	return noise_location
	
	
func attack() -> void:
	if attack_timer.is_stopped():
		attack_timer.start(attack_cooldown)
	else:
		return
		
	var camera = Global.player.CAMERA_CONTROLLER
	var circle = circle_scene.instantiate()
	var spell = Spell.new()
	spell.spell_name = "hgalsooo"
	spell.spell_text = "HELLO I COME FOR YOU "
	spell.circle_radius = 60
	circle.spell = spell
	Global.world.add_child(circle)

	var vFront = camera.project_ray_normal(get_viewport().size / 2)
	
	circle.global_position = camera.global_position + vFront * 2
	Vector3Ad.face_at(circle, camera.global_position)
	circle.create_spell_circle()
	
	var ray = Vector3Ad.cast_ray_from_camera(camera)
	
	if ray:	
		_test_raycast(ray.get("position"), ray.get("normal"), ray.get("collider"))
		

func telekinesis() -> void:
	var camera = Global.player.CAMERA_CONTROLLER
	var screen_center = get_viewport().size / 2
	var vFront = camera.project_ray_normal(screen_center)
	
	update_weapon()
		
	
	if telekinesis_object:
		var dis_to_tel = telekinesis_object.global_position - tip.global_position
		if not telekinesis_radius:
			telekinesis_radius = dis_to_tel.length()
		var tele_point = vFront * telekinesis_radius
		var power = telekinesis_power / telekinesis_object.mass
		var dir_to_point = tele_point + camera.global_position - telekinesis_object.global_position
		
		telekinesis_curve.create_quad_bezier(tip.global_position, tele_point, 
											 telekinesis_object.global_position)
											
		var tele_mass = telekinesis_object.mass
		var cur_vel = telekinesis_object.linear_velocity
		var max_vel = Vector3Ad.clamp_length(dir_to_point * power ** 2, 
											 cur_vel.length(), MAX_TELEKINESIS_VELOCITIY) 
		var min_vel = Vector3Ad.clamp_length(cur_vel.normalized() * cur_vel.length() ** 2, 
											 0, max_vel.length())
		var force = telekinesis_object.mass * (max_vel - min_vel) * 0.5 * dir_to_point.length()
		var damping_vel = cur_vel * tele_mass
		telekinesis_object.apply_central_force(force + tele_mass * Vector3.UP * Global.gravity
											   - damping_vel)
		
		return
			
	Global.player.ANIMATIONPLAYER.play("telekinesis")
		
	var ray = Vector3Ad.cast_ray_from_camera(camera, telekinesis_distance)
	
	if ray.get("collider") is RigidBody3D:
		ray.get("collider").create_glowing()
		telekinesis_object = ray.get("collider")
		
		
func remove_telekinesis():
	Global.player.ANIMATIONPLAYER.stop()
	if telekinesis_object:
		telekinesis_curve.delete_curve()
		telekinesis_object.remove_glowing()
		telekinesis_object = null
		telekinesis_radius = 0
		
		
func _test_raycast(pos: Vector3, normal: Vector3, collider) -> void:
	if collider is CSGDestrutibleObject:
		collider.warp_shape(pos - collider.global_position, 1, 2, 2)
		

	#var instance = raycast_test.instantiate()
	#get_tree().root.add_child(instance)
	#instance.global_position = pos
	#if normal != Vector3.UP and normal != Vector3.DOWN:
		#instance.look_at(instance.global_transform.origin + normal, Vector3.UP)
		#instance.rotate_object_local(Vector3(1, 0, 0), -PI/2)
	#await get_tree().create_timer(3).timeout
	#instance.queue_free()
	
