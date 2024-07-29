extends Camera2D


var zoom_min := Vector2(.2, .2)
var zoom_max := Vector2(2, 2)
var zoom_step := Vector2(1, 1) * 1.1
	

func _input(event):
	if event is InputEventMouseMotion:
		if event.button_mask == 4:
			position -= event.relative / zoom
			
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				if zoom > zoom_min:
					zoom_at_point(1/zoom_step.x, event.position)
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				if zoom < zoom_max:
					zoom_at_point(zoom_step.x, event.position)
					
			#if event.button_index == MOUSE_BUTTON_RIGHT:
				#var menu_offset = Vector2(14, 14)
				#%MouseMenu.visible = true
				#var width = ProjectSettings.get_setting("display/window/size/viewport_width")
				#var height = ProjectSettings.get_setting("display/window/size/viewport_height")
				#%MouseMenu.position = event.position
				#var vec = Vector2i(Vector2(width, height) - event.position)
				#if vec.x < %MouseMenu.size.x:
					#%MouseMenu.position.x = Vector2i(event.position).x + \
											#vec.x - %MouseMenu.size.x
				#if vec.y < %MouseMenu.size.y:
					#%MouseMenu.position.y = Vector2i(event.position).y + \
											#vec.y - %MouseMenu.size.y

					
func zoom_at_point(zoom_change, point):
	var c0 = global_position # camera position
	var v0 = get_viewport().size # vieport size
	var c1 # next camera position
	var z0 = zoom # current zoom value
	var z1 = z0 * zoom_change # next zoom value

	c1 = c0 + (-0.5 * v0 + Vector2(v0) - point) * (z0 - z1)
	zoom = z1
	global_position = c1
