extends MeshInstance3D

@onready var count = 0
	

func _process(_delta):
	if mesh and count == 0:
		count += 1
		rotate_texture()
		
		
func rotate_texture():
	var texture = mesh.material.albedo_texture
	var image = texture.get_image()
	image.decompress()
	image.rotate_90(CLOCKWISE)
	texture = ImageTexture.create_from_image(image)
	mesh.material.albedo_texture = texture
