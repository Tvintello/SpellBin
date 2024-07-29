extends Node


func create_circle_polygon(radius: float, segments: int) -> ConvexPolygonShape2D:
	var poly = ConvexPolygonShape2D.new()
	var array = PackedVector2Array()
	
	for i in range(segments):
		var x = cos(PI * 2 * i / segments)
		var y = sin(PI * 2 * i / segments)
		array.append(Vector2(x, y) * radius)
		
	poly.points = array
		
	return poly
	
	
func create_circle_array(radius: float, segments: int, vec3: bool = false, basis: Basis = Basis.IDENTITY) -> Array:
	var array : Array
	
	if vec3:
		array = PackedVector3Array()
	else:
		array = PackedVector2Array()
	
	for i in range(segments):
		var x = cos(PI * 2 * i / segments)
		var y = sin(PI * 2 * i / segments)
		if vec3: 
			array.append(Vector3(x, y, 0) * radius * basis)
		else:
			array.append(Vector2(x, y) * radius)
		
	return array
	
