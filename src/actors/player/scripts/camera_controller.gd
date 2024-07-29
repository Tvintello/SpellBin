extends Node3D


var _end_position : Vector3
var _lerp_position_weight : float = 0.2
var _is_pos_interpolating : bool = false
var _end_rotation : Vector3
var _lerp_rotation_weight : float = 0.2
var _is_rot_interpolating : bool = false


func _process(delta):
	if _is_pos_interpolating:
		global_position = lerp(global_position, _end_position, _lerp_position_weight)
		if Vector3Ad.round_by(global_position, 2) == _end_position:
			_is_pos_interpolating = false
		
	if _is_rot_interpolating:
		rotation = lerp(rotation, _end_rotation, _lerp_rotation_weight)
		if Vector3Ad.round_by(rotation, 2) == _end_rotation:
			_is_rot_interpolating = false
		
		
func interpolate_position(end_pos : Vector3, weight : float):
	_end_position = Vector3Ad.round_by(end_pos, 2)
	_lerp_position_weight = weight
	_is_pos_interpolating = true
	

func interpolate_rotation(end_rot : Vector3, weight : float):
	_end_rotation = Vector3Ad.round_by(end_rot, 2)
	_lerp_rotation_weight = weight
	_is_rot_interpolating = true
	
