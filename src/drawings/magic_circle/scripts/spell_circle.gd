class_name SpellCircle extends MeshInstance3D


const circle_texture_dir = "res://assets/textures/drawings/magic_circle/"
const spell_dir = "res://assets/resources/spells/"
var spell_dict : Dictionary
var spell : Spell:
	set(value):
		spell = value
		add_child(value)
		
var drawer_scene : PackedScene = \
	preload("res://src/drawings/magic_circle/scenes/circle_drawer.tscn")
var inner_radius : int
var outer_radius : int
var circle_texture : Texture2D

@onready var prev_radius : int = 0

@export var ANIMATION_PLAYER : AnimationPlayer
@export var ANIMATION_PANEL : MeshInstance3D
@export var pixel_size : float = 0.01


func _ready():
	spell = Spell.new()
	spell.spell_name = spell_dict.get("name")
	spell.commands = spell_dict.get("commands")
	
	inner_radius = spell_dict.get("inner_radius")
	outer_radius = spell_dict.get("outer_radius")
	
	if not mesh:
		mesh = QuadMesh.new()  # complusory !!!
		var file = spell_dict.get("circle_image")

		#if file and not FileManager.is_in_dir(circle_texture_dir, file):
			#draw_circle()
		circle_texture = load(file)
				
		bind_texture()

	
func delete_circle():
	queue_free()
	
	
func get_texture():
	return circle_texture
	

func get_radius():
	return outer_radius
		
		
func bind_texture():
	var mat = StandardMaterial3D.new()
	
	mat.albedo_texture = circle_texture
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_HASH
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material = mat
	mesh.size = Vector2(outer_radius * 2 * pixel_size, 
						outer_radius * 2 * pixel_size)
		
	
func draw_circle(pos: Vector2 = Vector2.ZERO, font_size: int = 16, width: int = 1, 
				 color: Color = Color.WHITE, circle_offset: int = 2) -> void:
					
	var instance = drawer_scene.instantiate()
	var drawer : CircleDrawerManager = instance
	add_child(instance)
	
	#if prev_radius:
		## temporary
		#var cur_radius : int = spell.circle_radius + width / 2
		#if cur_radius > prev_radius:
			#cur_radius = prev_radius
		#cur_radius -= width / 2
		#prev_radius = cur_radius
		##func(cur_radius)
	
	#drawer.draw_hollow_circle(spell.circle_radius, spell.circle_radius,
						 	  #width, pos, color)
	#
#
	#drawer.draw_rounded_string(spell.circle_radius - font_size / 2 - circle_offset / 2 - 1, 
							   #spell.spell_text, font_size, pos)
	#
	#drawer.draw_hollow_circle(spell.circle_radius - font_size - circle_offset, 
							  #spell.circle_radius, width, pos, color)
		#
	#drawer.save_circle(spell.circle_radius, circle_texture_dir + 
					   #spell.spell_name + spell.file_type)
	#
	#spell.circle_texture = drawer.get_texture()
	
	drawer.draw_hollow_circle(spell.circle_radius, spell.circle_radius,
						 	  width, pos, color)
							
	drawer.save_flex_texture("circle_preview", {"draw_hollow_circle": ["radius"], "draw_string": ["font_size"]})
