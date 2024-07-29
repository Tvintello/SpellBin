class_name Player
extends CharacterBody3D


# mouse action restraints
const MOUSE_FREE = 0
const DISABLE_WEAPON = 1
const DISABLE_PLAYER = 2
const DISABLE_WEAPON_AND_PLAYER = 3

# movement action restraints
const PLAYER_FREE = 0
const STOP_CAMERA_MOVEMENT = 1
const STOP_PLAYER_MOVEMENT = 2
const STOP_PLAYER_AND_CAMERA_MOVEMENT = 3

@export var MOUSE_SENSITIVITY : float = 0.5
@export var TILT_LOWER_LIMIT := -PI / 2
@export var TILT_UPPER_LIVIT := PI / 2
@export var CAMERA_CONTROLLER : Camera3D
@export var ANIMATIONPLAYER : AnimationPlayer
@export var WEAPON_CONTROLLER : WeaponController
@export var mana_uploading_speed : float = 1
@export var max_mana_amount : float = 200
@export var mana_amount : float = 200

@onready var INTERACTION_RAY : RayCast3D = %InteractionRay
@onready var DRAWING_RAY : RayCast3D = %DrawingRay
@onready var WEAPON_CAMERA = %WeaponCamera
@onready var EDITING_SCENE = preload("res://src/circle_editor/new edition/scenes/circle_editor.tscn")
@onready var INITIAL_CAMERA_POSITION : Vector3 = CAMERA_CONTROLLER.position
@onready var CURSOR_PROGRESS_BAR : TextureProgressBar = \
	%UI.get_help_container().get_node("BarContainer/Bar")

var _mouse_input : bool = false
var _mouse_rotation: Vector3
var _rotation_input : float
var _tilt_input : float
var _player_rotation : Vector3
var _camera_rotation : Vector3
var _is_crouching : bool = false
var _help_collider
var _end_rotation : Vector3
var _lerp_rotation_weight : float = 0.2
var _is_rot_interpolating : bool = false

var player_movement : int

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	CURSOR_PROGRESS_BAR.get_parent().visible = false
	Global.player = self
	#get_window().mode = Window.MODE_WINDOWED
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(e : InputEvent):
	if e.is_action_pressed("exit"):
		get_tree().quit()
			
			
func _process(delta):
	_process_input(delta)
	if _is_rot_interpolating:
		rotation = lerp(rotation, _end_rotation, _lerp_rotation_weight)
		if Vector3Ad.round_by(rotation, 2) == Vector3Ad.round_by(_end_rotation, 2):
			_is_rot_interpolating = false
		
		
func _process_input(delta):
	var is_spell_drawing = false
	var collider = null
	
	if INTERACTION_RAY.is_colliding():
		collider = INTERACTION_RAY.get_collider().get_parent()
		if "type" in collider and collider.type == "spell_drawing":
			CURSOR_PROGRESS_BAR.get_parent().visible = true
			CURSOR_PROGRESS_BAR.max_value = collider.max_mana_amount
			CURSOR_PROGRESS_BAR.value = collider.mana_amount
			is_spell_drawing = true
			_help_collider = collider
			
			for btn in collider.help_buttons:
				if not %UI.get_help_container().get_node_or_null(btn["name"]):
					var child = %UI.help_button.instantiate()
					child.name = btn["name"]
					var label = child.get_node("Description")
					label.text = btn["description"]
					var key = child.get_node("TextureRect/Key")
					key.char = btn["char"]
					%UI.get_help_container().add_child(child)
				
		else:
			CURSOR_PROGRESS_BAR.get_parent().visible = false
	else:
		CURSOR_PROGRESS_BAR.get_parent().visible = false
		if _help_collider:
			for btn in _help_collider.help_buttons:
				%UI.get_help_container().remove_child(
					%UI.get_help_container().get_node(btn["name"]))
			_help_collider = false
			
		
	if Input.is_action_pressed("interaction"):	
		if collider is SpellCircle or collider is ManaCollector:
			collider.collect_mana(self, mana_uploading_speed * delta)
			
			
	if Input.is_action_just_pressed("edit_circle"):	
		if collider is SpellCircle:
			CAMERA_CONTROLLER._init_camera_pos = CAMERA_CONTROLLER.global_position
			print(CAMERA_CONTROLLER._init_camera_pos)
			
			immobilize()
			
			var ground_offset = collider.global_basis.z.normalized()
			var parent = CAMERA_CONTROLLER.get_parent()
			
			parent.position = CAMERA_CONTROLLER.position
			parent.rotation = CAMERA_CONTROLLER.rotation
			
			parent.interpolate_position(collider.global_position, 0.1)
			parent.interpolate_rotation(collider.rotation, 0.1)
			
			CAMERA_CONTROLLER.position = Vector3(0, 0, ground_offset.length())
			CAMERA_CONTROLLER.rotation = Vector3.ZERO
			
			CAMERA_CONTROLLER.turn_on_free_camera()
			
			open_circle_editor()
			
			
func immobilize() -> void:
	player_movement = STOP_PLAYER_AND_CAMERA_MOVEMENT
	restrain_mouse_input(DISABLE_WEAPON_AND_PLAYER)
	
	
func free() -> void:
	player_movement = PLAYER_FREE
	restrain_mouse_input(MOUSE_FREE)
			
			
func open_circle_editor() -> void:
	%UI.visible = false
	%PlayerStateMachine.disabled = true
	%WeaponCameraContainer.visible = false
	%CircleEditor.visible = true
	
	
func close_circle_editor() -> void:
	%UI.visible = true
	%PlayerStateMachine.disabled = false
	%WeaponCameraContainer.visible = true
	%CircleEditor.visible = false


func interpolate_rotation(rot: Vector3, weight: float):
	_end_rotation = rot
	_lerp_rotation_weight = weight
	_is_rot_interpolating = true
		
		
func restrain_mouse_input(index: int = 0):
	match index:
		1:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			WEAPON_CONTROLLER.disabled = true
		2:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			WEAPON_CONTROLLER.disabled = false
		3:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			WEAPON_CONTROLLER.disabled = true
		4:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			WEAPON_CONTROLLER.disabled = true
		_:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			WEAPON_CONTROLLER.disabled = false
			
			
func is_player_movable() -> bool:
	return player_movement != STOP_PLAYER_MOVEMENT and \
		   player_movement != STOP_PLAYER_AND_CAMERA_MOVEMENT
		
		
func is_camera_movable() -> bool:
	return player_movement != STOP_CAMERA_MOVEMENT and \
		   player_movement != STOP_PLAYER_AND_CAMERA_MOVEMENT
			
		
func _unhandled_input(event):
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == \
		Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY
		
		
func _update_camera(delta):
	if not is_camera_movable():
		return
		
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIVIT)
	_mouse_rotation.y += _rotation_input * delta
	
	_player_rotation = Vector3(0.0, _mouse_rotation.y, 0.0)
	_camera_rotation = Vector3(_mouse_rotation.x, 0.0, 0.0)
	
	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	CAMERA_CONTROLLER.rotation.z = 0.0
	
	global_basis = Basis.from_euler(_player_rotation)
	
	_rotation_input = 0.0
	_tilt_input = 0.0
	

func _physics_process(delta):
	Global.debug.add_property("Current velocity", velocity, 1)	
	Global.debug.add_property("Height", position.y, 1)	
	_update_camera(delta)
	
	
func set_mouse_rotation(rot: Vector3, delta: float):
	_mouse_rotation = rot
	_update_camera(delta)

	
func update_gravity(delta) -> void:
	velocity.y -= gravity * delta
	
	
func update_input(speed: float, acceleration: float, deceleration: float) -> void:
	if not is_player_movable():
		return
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration)
		velocity.z = lerp(velocity.z, direction.z * speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)
		velocity.z = move_toward(velocity.z, 0, deceleration)
	
	
func update_velocity() -> void:
	move_and_slide()
	
	
func update_collision() -> void:
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			var push_dir = -c.get_normal()
			# How much velocity the object needs to increase 
			# to match player velocity in the push direction
			var velocity_diff_in_push_dir = self.velocity.dot(push_dir) - \
							c.get_collider().linear_velocity.dot(push_dir)
			# Only count velocity towards push dir, away from character
			velocity_diff_in_push_dir = max(0., velocity_diff_in_push_dir)
			# Objects with more mass than us should be harder to push. 
			# But doesn't really make sense to push faster than we are going
			const MY_APPROX_MASS_KG = 80.0
			var mass_ratio = min(1., MY_APPROX_MASS_KG / c.get_collider().mass)
			# Optional add: Don't push object at all if it's 4x heavier or more
			if mass_ratio < 0.25:
				continue
			# Don't push object from above/below
			push_dir.y = 0
			# 5.0 is a magic number, adjust to your needs
			var push_force = mass_ratio * 5.0
			c.get_collider().apply_impulse(push_dir * velocity_diff_in_push_dir * \
										   push_force, c.get_position() - \
										   c.get_collider().global_position)

			
	
