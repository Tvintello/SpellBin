extends Node2D


@export var font : Font = SystemFont.new()
@export var font_size : int
@export var char_position := Vector2(0, 0)
var char : String


func _draw():
	draw_char(font, char_position, char, font_size, Color.BLACK)
