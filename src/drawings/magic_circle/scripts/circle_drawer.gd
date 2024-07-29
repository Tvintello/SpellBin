class_name CircleDrawer extends Node2D


var actions : Array
var main_radius : int


func _draw():
	for act in actions:
		call(act[0], act[1])
	
	
func set_image_size(pars: Dictionary):
	get_viewport().size = Vector2(pars["radius"] * 2, pars["radius"] * 2)
	position = get_viewport().size / 2
		
	
func save_circle(pars: Dictionary):
	var view = get_viewport()
	await RenderingServer.frame_post_draw
	view.size = Vector2(pars["radius"] * 2, pars["radius"] * 2)
	position = view.size / 2
	view.get_texture().get_image().save_png(pars["path"])
	
	
func draw_hollow_circle(pars: Dictionary) -> void:
	var prev_pos : Vector2 = Vector2(1, 0) * pars["radius"] + pars["pos"]
	
	for i in range(pars["segments"]):
		var cur_pos = Vector2(cos(PI * 2 * (i + 1) / pars["segments"]), 
							  sin(PI * 2 * (i + 1) / pars["segments"])) * pars["radius"] + pars["pos"]
		draw_line(prev_pos, cur_pos, pars["color"], pars["width"])
		prev_pos = Vector2(cur_pos)


func draw_rounded_string(pars: Dictionary):
	var seg = 2 * PI * pars["radius"] / len(pars["text"])
	if seg < pars["font_size"]:
		pars["font_size"] = round(seg)
	
	for ch in range(len(pars["text"])):
		var char_node = Node2D.new()
		var char_pos = Vector2(cos(PI * 2 * ch / len(pars["text"])), 
							  sin(PI * 2 * ch / len(pars["text"]))) * pars["radius"] + pars["pos"] 
		char_node.set_script(load("res://scene_objects/drawings/magic_circle/scripts/circle_label.gd"))
		char_node.position = char_pos
		char_node.look_at(pars["pos"])
		char_node.rotation -= PI / 2
		char_node.label_font = pars["font"]
		char_node.label_pos = pars["font"].get_char_size(pars["text"][ch].to_ascii_buffer()[0], pars["font_size"]) * Vector2(-0.5, 0.25)
		char_node.label_text = pars["text"][ch]
		char_node.label_font_size = pars["font_size"]
		add_child(char_node)
	
