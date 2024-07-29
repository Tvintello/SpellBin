class_name EditorNode extends Panel


static var scene = preload("res://src/circle_editor/scenes/editor_node.tscn")


func _gui_input(event):
	if event is InputEventMouseMotion:
		if event.button_mask == 1:
			position += event.relative
