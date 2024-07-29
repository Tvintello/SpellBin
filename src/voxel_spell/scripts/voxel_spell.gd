class_name VoxelSpell extends VoxelLodTerrain


const spell_generator = preload("res://src/voxel_spell/scripts/spell_generator.gd")


func _ready():
	generator = spell_generator.new()
