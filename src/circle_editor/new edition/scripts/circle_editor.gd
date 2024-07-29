extends Control


func _ready():
	visible = false
	%PopupPanel.position = DisplayServer.window_get_size() / 2 - %PopupPanel.size / 2


func _process(delta):
	pass


func get_background() -> TextureRect:
	return %Background


func _on_open_editor_button_down():
	%TextEdit.visible = !%TextEdit.visible
	if %TextEdit.mouse_filter != MOUSE_FILTER_STOP:
		%TextEdit.mouse_filter = MOUSE_FILTER_STOP
	else:
		%TextEdit.mouse_filter = MOUSE_FILTER_IGNORE


func _on_save_btn_button_up():
	%PopupPanel.visible = true


func _on_accept_button_button_up():
	print("SAVED")
	# json saving
	var dict = {
		"name": %SpellName.text,
		"description": %Description.text,
		"circle_image": "res://assets/textures/drawings/magic_circle/empty_circle.png",
		"inner_radius": 20,
		"outer_radius": 60,
		"commands": Spell.compile(%TextEdit.text)
	}
	
	var json = JSON.stringify(dict)
	var count = len(DirAccess.get_files_at("res://assets/resources/spells/"))
	var file_name = "res://assets/resources/spells/spell%d.json" % count
	var file = FileAccess.open(file_name, FileAccess.WRITE)
	file.store_string(json)
	
	# circle editor closing
	var camera = Global.player.CAMERA_CONTROLLER
	camera.turn_off_free_camera()
		
	Global.player.player_movement = Player.PLAYER_FREE
	Global.player.restrain_mouse_input(Player.MOUSE_FREE)
	
	camera.get_parent().global_position = camera._init_camera_pos
	camera.get_parent().rotation = Vector3.ZERO
	
	camera.position = Vector3.ZERO
	camera.rotation = Vector3.ZERO
	
	Global.player.close_circle_editor()
	camera.set_process_input(false)
	
	%PopupPanel.visible = false


func _on_cancel_button_button_up():
	%PopupPanel.visible = false
