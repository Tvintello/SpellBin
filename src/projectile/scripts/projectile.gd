class_name Projectile extends Node3D


@export var SPEED : float = 1

@onready var mesh_instance = %MeshInstance3D
@onready var ray : RayCast3D = %RayCast3D
var direction : Vector3


func _ready():
	await get_tree().create_timer(10).timeout
	queue_free()
	

func _process(delta):
	position += transform.basis * direction * SPEED * delta
	
	if ray.is_colliding():
		queue_free()
