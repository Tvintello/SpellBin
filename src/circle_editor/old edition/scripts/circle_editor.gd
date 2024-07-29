extends GraphEdit


func _input(event : InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			show_mouse_menu(event.position)


func show_mouse_menu(pos: Vector2, menu_offset := Vector2(-3, -3)) -> void:
	%MouseMenu.visible = true
	var width = ProjectSettings.get_setting("display/window/size/viewport_width")
	var height = ProjectSettings.get_setting("display/window/size/viewport_height")
	%MouseMenu.position = pos + menu_offset
	var vec = Vector2i(Vector2(width, height) - pos)
	if vec.x < %MouseMenu.size.x:
		%MouseMenu.position.x = Vector2i(pos).x + \
								vec.x - %MouseMenu.size.x
	if vec.y < %MouseMenu.size.y:
		%MouseMenu.position.y = Vector2i(pos).y + \
								vec.y - %MouseMenu.size.y	
				

