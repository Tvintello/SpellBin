extends Node2D


var label_text : String
var label_font : Font
var label_font_size : int = 16
var label_pos : Vector2
var label_text_color : Color = Color.WHITE


func _draw():
	draw_char(label_font, label_pos, label_text, label_font_size, label_text_color)
	


	
