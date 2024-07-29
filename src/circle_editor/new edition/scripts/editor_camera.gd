extends Camera3D


@export var zoom_min := .2
@export var zoom_max := 2
@export var zoom_step := 0.1
@export var pixel_size := 0.0023

var _end_position : Vector3
var _lerp_position_weight : float = 0.2
var _is_pos_interpolating : bool = false
var _end_rotation : Vector3
var _lerp_rotation_weight : float = 0.2
var _is_rot_interpolating : bool = false
var _init_camera_pos : Vector3


func _ready():
	set_process_input(false)
	

func _input(event):
	if event.is_action_pressed("exit"):
		turn_off_free_camera()
		
		Global.player.player_movement = Player.PLAYER_FREE
		Global.player.restrain_mouse_input(Player.MOUSE_FREE)
		
		get_parent().global_position = _init_camera_pos
		get_parent().rotation = Vector3.ZERO
		
		position = Vector3.ZERO
		rotation = Vector3.ZERO
		
		Global.player.close_circle_editor()
		set_process_input(false)
		
		get_viewport().set_input_as_handled()
		
	if event is InputEventMouseMotion:
		if event.button_mask == 4:
			var pos = Vector3(-event.relative.x, event.relative.y, 0)
			position += pos * pixel_size * position.z 
			
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				if position.z < zoom_max:
					position.z += zoom_step	
					
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				if position.z > zoom_min:
					position.z -= zoom_step		
					
					
func zoom_at_point(zoom_change, point):
	var c0 = Vector2(position.x, position.y) # camera position
	var v0 = get_viewport().size # vieport size
	var c1 # next camera position
	var z0 = position.z # current zoom value
	var z1 = z0 * zoom_change # next zoom value

	c1 = c0 + (-0.5 * v0 + Vector2(point.x, v0.y - point.y)) * (z0 - z1)
	c1 = c1 * pixel_size + c0
	position = Vector3(c1.x, c1.y, z1 + position.z)
	
	
func turn_on_free_camera():
	set_process_input(true)
	%InteractionRay.enabled = false
	%DrawingRay.enabled = false
	
	
func turn_off_free_camera():
	set_process_input(false)
	%InteractionRay.enabled = true
	%DrawingRay.enabled = true
	
	
	
