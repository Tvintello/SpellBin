extends Label3D


func _process(_delta):
	rotation = Global.player.CAMERA_CONTROLLER.global_rotation
	
	
func update(new_text: Variant):
	text = str(new_text)
	
