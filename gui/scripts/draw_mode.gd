class_name DrawMode extends Control


const ACCEPT_COLOR = Color(0, 2, 0)
const REJECT_COLOR = Color(2, 0, 0)


@export var drawing_distance : float = 3

@onready var ground_offset : float = 0.05

var instance : Node3D
var _is_preview : bool = false


func _ready():
	visible = false
	var blackout = get_node_or_null("Blackout")
	
	if blackout:
		blackout.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		
func _input(event):
	# preview
	
	
	# cancel drawing
	if event.is_action_pressed("exit") and visible:
		visible = false
		delete_instance()
		accept_event()


func _process(delta):
	show_preview()
	if Input.is_action_just_pressed("draw"):
		place()


func open():
	Global.player.restrain_mouse_input(Player.DISABLE_WEAPON)
	visible = true
	
	
func close():
	Global.player.restrain_mouse_input(Player.MOUSE_FREE)
	visible = false
	
	
func delete_instance():
	if instance and _is_preview:
		instance.queue_free()
		_is_preview = false
	
	
func show_preview() -> void:
	if not visible:
		return 
		
	var ray = Global.player.DRAWING_RAY 
	
	if ray.is_colliding():
		instance.update_position(ray.get_collision_point(), 
								 ray.get_collision_normal(), ground_offset)
		instance.visible = true
	else:
		instance.visible = false
	
	
func place() -> void:
	if not visible or not instance.visible:
		return 
		
	_is_preview = instance.exit(Global.player.DRAWING_RAY)
		
	if not _is_preview:
		close()
	
	
func create_instance(cls: GDScript, pars: Dictionary) -> void:
	delete_instance()
		
	instance = cls.new()
	instance.enter(pars)
	Global.world.add_child(instance)
	_is_preview = true
	
