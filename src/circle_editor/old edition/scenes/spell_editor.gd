extends Control


func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():		
			if event.button_index == MOUSE_BUTTON_RIGHT:
				%MouseMenu.visible = true
				var width = ProjectSettings.get_setting("display/window/size/viewport_width")
				var height = ProjectSettings.get_setting("display/window/size/viewport_height")
				%MouseMenu.position = event.position
				var vec = Vector2i(Vector2(width, height) - event.position)
				if vec.x < %MouseMenu.size.x:
					%MouseMenu.position.x = Vector2i(event.position).x + \
											vec.x - %MouseMenu.size.x
				if vec.y < %MouseMenu.size.y:
					%MouseMenu.position.y = Vector2i(event.position).y + \
											vec.y - %MouseMenu.size.y
