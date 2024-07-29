extends Path3D


@onready var time: float = 0
@onready var timer: SceneTreeTimer = get_tree().create_timer(0.01)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if timer.time_left == 0:
		curve = Curve3D.new()
		
		for x in range(10):
			var y = sin(Time.get_ticks_msec() + x)
			curve.add_point(Vector3(x, y, 0))
			
		timer = get_tree().create_timer(0.08)

		
		
	
