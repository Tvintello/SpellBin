class_name ManaCollector extends MeshInstance3D


var scene : PackedScene = preload("res://src/drawings/scenes/interactible_object.tscn")
static var pixel_size : float = 0.01
static var type : String = "spell_drawing"

const DEFAULT_COLOR : Color = Color(0, 0, 0)

var texture = preload("res://assets/textures/drawings/mana_collector.png")
var collider : CollisionShape3D 
var collider_path : NodePath = "InteractibleObject/Collider"
var connected_drawings = []
var entry_positions = []
var max_mana_amount : float
var mana_amount : float
var mana_label : Label3D
var _is_placed : bool = false
var size : Vector2
var brightness : float = 3
var help_buttons : Array[Dictionary]

signal _mana_changed


func _ready() -> void:
	max_mana_amount = 2
	mana_amount = 0
	_mana_changed.connect(_on_mana_changed)
	
	collider.shape = BoxShape3D.new()
	collider.shape.size = Vector3(1, 1, 0) * size.x
	
	help_buttons = [
		{"name": "PourMana", "description": "Pour mana in collector", 
		 "char": "F"},
	]

	
func _process(_delta):
	if _is_placed:
		if mana_amount > max_mana_amount:
			mana_amount = max_mana_amount
			
		mana_label.update(mana_amount)
		
		if connected_drawings and mana_amount:
			transfer_mana()
			
		
func _on_mana_changed() -> void:
	var color = Color.WHITE * mana_amount / max_mana_amount * brightness
	color.a = 1
	set_color(color)
	
	
func create_circle_array(radius: float, segments: int) -> Array:
	var array : Array
	array = PackedVector3Array()
	
	for i in range(segments):
		var x = cos(PI * 2 * i / segments)
		var y = sin(PI * 2 * i / segments)
		
		var vec = Vector3(x, y, 0) * basis

		array.append(vec * radius)
		
	return array	
	
	
func get_texture():
	return texture
	

func get_radius():
	return texture.get_size().x
	
	
func reset_color() -> void:
	if mesh:
		mesh.material.albedo_color = DEFAULT_COLOR

	
func set_color(color: Color) -> void:
	if mesh:
		mesh.material.albedo_color = color
		
		
func add_color(color: Color) -> void:
	if mesh:
		mesh.material.albedo_color += color

	
func transfer_mana() -> void:
	if mana_amount <= max_mana_amount and connected_drawings:
		var amount = mana_amount / len(connected_drawings)
		for drawing in connected_drawings:
			drawing.mana_amount += amount
			drawing._mana_changed.emit()
			
		mana_amount = 0
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


func enter(pars: Dictionary):
	var instance = scene.instantiate()
	add_child(instance)
	collider = get_node_or_null(collider_path)
	collider.disabled = true
	mesh = QuadMesh.new()
	size = texture.get_size() * pixel_size * 2
	mesh.size = size
	
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = texture
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_HASH
	
	mesh.material = mat
	
	
func update_position(pos: Vector3, normal: Vector3, ground_offset: float):
	global_position = pos + normal * ground_offset
	Vector3Ad.face_at(self, Vector3Ad.round_by(normal, 3), true)
	

func exit(ray: RayCast3D) -> bool:
	collider.disabled = false
	
	var radius = texture.get_size().x * pixel_size
	entry_positions = create_circle_array(radius, 8)
	_is_placed = true
	
	mana_label = Display.create_label3d(Global.world, global_position + Vector3.UP * 1, mana_amount)
	reset_color()
	return false
	
