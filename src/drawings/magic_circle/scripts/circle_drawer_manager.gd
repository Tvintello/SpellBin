class_name CircleDrawerManager extends SubViewportContainer


@onready var actions : Array[Array] = []
@onready var drawer : CircleDrawer = $SubViewport/Canvas


func get_texture() -> Texture2D:
	return drawer.get_viewport().get_texture()
	
	
func load_actions(path: String) -> void:
	pass
	
	
func set_image_size(radius: float) -> void:
	drawer.set_image_size({"radius": radius})
		
	
func save_circle(radius: float, path: String) -> void:
	drawer.save_circle({"radius": radius, "path": path})
	
	
func draw_hollow_circle(radius: float, segments: int, width: float = 1, 
						pos: Vector2 = Vector2.ZERO, 
						color: Color = Color.WHITE) -> void:
	var pars = {"radius": radius, "segments": segments, 
				"width": width, "pos": pos, "color": color}
	drawer.actions.append(["draw_hollow_circle", pars])


func draw_rounded_string(radius: float, text: String, font_size: float, 
						 pos: Vector2 = Vector2.ZERO, 
						 font: Font = SystemFont.new()) -> void:
	var pars = {"radius": radius, "text": text, 
				"font_size": font_size, "pos": pos, "font": font}
	drawer.actions.append(["draw_rounded_string", pars])
	

func save_flex_texture(file_name: String, lack_pars: Dictionary) -> void:
	var json = JSON.stringify([actions, lack_pars])
	var file = FileAccess.open("res://scene_objects/drawings/magic_circle/
							   flex_textures/{f}.tres".format({"f": file_name}), 
							   FileAccess.WRITE)
	file.store_string(json)
	

