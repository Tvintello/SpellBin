extends MeshInstance3D


func _ready():
	pass # Replace with function body.


func _process(delta):
	rotation = transform.rotated(Vector3(0, 1, 0), 0.0055).basis.get_euler()
