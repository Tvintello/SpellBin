extends Camera3D


@export var MAIN_CAMERA : Node3D

func _ready():
	get_window().size_changed.connect(_on_size_changed)


func _process(_delta):
	global_transform = MAIN_CAMERA.global_transform
	
	
func _on_size_changed():
	get_parent().size = get_window().size
