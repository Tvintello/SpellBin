extends Node


var debug
var player : Player
var light_source : DirectionalLight3D

@onready var spell_circle_dir = "res://scene_objects/magic_circle/textures/"
@onready var world = get_tree().root.get_node_or_null("World")
@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	if world:
		light_source = world.get_node_or_null("LightSource")
