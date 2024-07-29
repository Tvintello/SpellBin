extends PopupMenu


@export var editor : GraphEdit

var nodes_path : String = "res://src/circle_editor/graph_nodes/"


func _input(event : InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if not get_visible_rect().has_point(event.position):
				visible = false
				
				
func get_graph_node(gr_name: String):
	return load(nodes_path + gr_name + ".tscn").instantiate()
	

func _on_id_pressed(id):
	if id == 0:
		var node : GraphNode = get_graph_node("node")
		node.size = Vector2(200, 200)
		editor.add_child(node)
		node.position_offset = (Vector2(position) + editor.scroll_offset) / editor.zoom
		
		
		
		
