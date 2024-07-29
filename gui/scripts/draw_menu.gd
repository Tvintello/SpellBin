extends Control


@onready var main_parent = get_parent().get_parent()
@onready var circle_list = %CircleList
@onready var circle_scene = preload("res://gui/scenes/spell_circle.tscn")
@onready var draw_mode = get_parent().get_parent().get_draw_mode()


func _ready():
	visible = false
	%ButtonProcessor.draw_menu = self
	load_saved_circles()
	
	
func _input(event):
	if event.is_action_pressed("exit"):
		if visible:
			close()
			accept_event()


func _process(delta):	
	if Input.is_action_just_pressed("draw_menu") and main_parent.visible:
		draw_mode.close()
		
		if visible:
			close()
		else:
			open()
			draw_mode.delete_instance()
		

func toggle_visibility() -> void:
	visible = !visible
	
	
func open() -> void:
	visible = true
	Global.player.immobilize() 


func close() -> void:
	visible = false
	Global.player.free()


func load_saved_circles() -> void:
	var dir = DirAccess.open(SpellCircle.spell_dir)
	
	if dir:
		dir.list_dir_begin()
		var f = dir.get_next()
		while f != "":
			if not dir.current_is_dir():
				var spell = FileManager.load_json_file(dir.get_current_dir() + "/" + f)
				var child = circle_scene.instantiate()
				child.get_preview().texture = load(spell.get("circle_image"))
				child.get_name_node().text = spell.get("name")
				child.spell_file_path = dir.get_current_dir() + "/" + f
				child.draw_menu = self
				circle_list.add_child(child)
				
			f = dir.get_next()
	else:
		push_error("An error occurred when trying to access the path to spell.")
