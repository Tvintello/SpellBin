class_name PlaceableSpellCircle extends SpellCircle


const DEFAULT_COLOR : Color = Color(0, 0, 0)

@onready var blowing_animation : Animation = Animation.new()

var scene : PackedScene = preload("res://src/drawings/scenes/interactible_object.tscn")
var type : String = "spell_drawing"
var entry_positions = []
var collider : CollisionShape3D 
var collider_path : NodePath = "Collider"
var anim_library : AnimationLibrary
var max_mana_amount : float
var mana_amount : float
var connected_drawings = []
var mana_label : Label3D
var _is_placed : bool = false
var brightness : float = 2
var help_buttons : Array[Dictionary]

signal _mana_changed


func _ready() -> void:
	super()
	
	max_mana_amount = 2
	mana_amount = 0
	
	var size = outer_radius * pixel_size * 2
	collider.shape = BoxShape3D.new()
	collider.shape.size = Vector3(1, 1, 0) * size
	
	_mana_changed.connect(_on_mana_changed)
	
	help_buttons = [
		{"name": "PourMana", "description": "Pour mana in circle", "char": "F"},
		{"name": "EditCircle", "description": "Edit circle", "char": "C"},
	]
	
	#ANIMATION_PLAYER.get_animation_library("").add_animation("blowing_animation", blowing_animation)
	
	
func _process(delta):
	if _is_placed:		
		mana_label.update(mana_amount)
		if mana_amount >= max_mana_amount:
			activate_spell()
			mana_amount -= max_mana_amount
			_mana_changed.emit()
		
		
func _on_mana_changed() -> void:
	var color = Color.WHITE * mana_amount / max_mana_amount * brightness
	color.a = 1
	set_color(color)
	
	
func transfer_mana() -> void:
	if mana_amount <= max_mana_amount and connected_drawings:
		var amount = mana_amount / (len(connected_drawings) + 1)
		for drawing in connected_drawings:
			drawing.collect_mana(self, amount)
		
		_mana_changed.emit()
		
		
func collect_mana(obj: Object, amount: float) -> void:
	if mana_amount < max_mana_amount:
		if obj.mana_amount > amount:
			mana_amount += amount
			obj.mana_amount -= amount
		elif obj.mana_amount < amount and obj.mana_amount > 0:
			mana_amount += amount - obj.mana_amount
			obj.mana_amount = 0
			
		_mana_changed.emit()
	
	
func create_circle_array(radius: float, segments: int) -> Array:
	var array : Array
	array = PackedVector3Array()
	
	for i in range(segments):
		var x = cos(PI * 2 * i / segments)
		var y = sin(PI * 2 * i / segments)
		
		var vec = Vector3(x, y, 0) * basis
		
		array.append(vec * radius)
		
	return array
	
	
func _create_key_frames():
	var frame_quantity = 10
	var anim_speed : float = 0.5
	blowing_animation.length = frame_quantity * anim_speed
	
	var ins = drawer_scene.instantiate()
	var drawer = ins.get_child(0).get_child(0)
	add_child(ins)
	var start_radius = spell.circle_radius
	var end_radius = start_radius * 4
	
	var index = blowing_animation.add_track(Animation.TYPE_VALUE)
	var image_size = ANIMATION_PANEL.mesh.size.x / (2 * pixel_size)
	var count = 0
	
	for f in range(frame_quantity + 1):
		var draw_calls = [['set_image_size', {"radius": image_size}]]
		var radius = f * (end_radius - start_radius) / frame_quantity + start_radius
		
		var pars = {
			"radius": radius, 
			"segments": radius, 
			"pos": Vector2.ZERO, "width": 4, "color": Color.WHITE
		}
		
		draw_calls.append(['draw_hollow_circle', pars])
		
		#draw_calls.append(["save_circle", {"radius": image_size, 
						   #"file_name": instance.spell.spell_name + str(radius) + instance.spell.file_type, 
						   #"main_dir": "res://text_folder/"}])
		
		drawer.actions = draw_calls
		
		drawer.queue_redraw()
		
		await RenderingServer.frame_post_draw
		blowing_animation.track_set_path(index, "AnimationPanel:mesh:material:albedo_texture")
		#var dir = DirAccess.open("res://text_folder/")
		#var files = Array(dir.get_files())
		#files = files.filter(func (x): return x.split(".")[-1] != "import")
		#load("res://text_folder/" + files[count])
		blowing_animation.track_insert_key(index, f * anim_speed, drawer.get_viewport().get_texture())
		blowing_animation.value_track_set_update_mode(index, Animation.UPDATE_DISCRETE)
		#count += 1
	
	
func activate_spell():
	spell.execute()
	#instance.ANIMATION_PLAYER.play("blowing_animation")
	
	
func reset_color() -> void:
	if mesh:
		mesh.material.albedo_color = DEFAULT_COLOR

	
func set_color(color: Color) -> void:
	if mesh:
		mesh.material.albedo_color = color
		
		
func add_color(color: Color) -> void:
	if mesh:
		mesh.material.albedo_color += color
	
	
func enter(pars: Dictionary):
	var instance = scene.instantiate()
	add_child(instance)
	spell_dict = pars["spell_dict"]
	collider = instance.get_node_or_null(collider_path)
	collider.disabled = true
	
	
func update_position(pos: Vector3, normal: Vector3, ground_offset: float):
	global_position = pos + normal * ground_offset
	Vector3Ad.face_along(self, Vector3Ad.round_by(normal, 3), true)
	
	
func exit(ray: RayCast3D) -> bool:
	collider.disabled = false
	spell.transform.basis = Basis(transform.basis)
	
	var radius = outer_radius * pixel_size
	entry_positions = create_circle_array(radius, 8)
	
	mana_label = Display.create_label3d(Global.world, global_position + Vector3.UP * 1, mana_amount)
	
	_is_placed = true
	reset_color()
	return false

	
