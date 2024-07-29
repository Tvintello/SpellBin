extends HBoxContainer


var draw_menu
var spell_file_path


func get_preview() -> TextureRect:
	return %CirclePreview


func get_name_node() -> Label:
	return %Name


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1:
			if draw_menu:
				var spell = FileManager.load_json_file(spell_file_path)

				draw_menu.draw_mode.create_instance(PlaceableSpellCircle, {"spell_dict": spell})
				draw_menu.close()
				draw_menu.draw_mode.open()
