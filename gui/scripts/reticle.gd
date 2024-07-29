extends Control


@export var DOT_RADIUS : float = 1.0
@export var DOT_COLOR : Color = Color.WHITE


func _ready():
	queue_redraw()
	mouse_filter = MOUSE_FILTER_IGNORE
	
	
func _draw():
	draw_circle(size / 2, DOT_RADIUS, DOT_COLOR)
