class_name BaseDrawing extends Node3D


static var pixel_size : float = 0.01
const DEFAULT_COLOR : Color = Color(0, 0, 0)
var mana_amount : float
var max_mana_amount : float


func reset_color() -> void:
	pass

	
func set_color(_color: Color) -> void:
	pass
		
		
func add_color(_color: Color) -> void:
	pass


func enter(_pars: Dictionary):
	pass
	
	
func update_position(_pos: Vector3, _normal: Vector3, _ground_offset: float):
	pass
	

func exit(_close_func: Callable, _ray: RayCast3D):
	pass
	
	
