class_name MobileScreen extends MeshInstance3D


var viewport_texture : ViewportTexture


func _ready():
	mesh = BoxMesh.new()
	mesh.flip_faces = true
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material = mat
