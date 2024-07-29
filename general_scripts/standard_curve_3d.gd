class_name StandardCurve3D extends Path3D


var polygon : CSGPolygon3D


func _ready():
	polygon.mode = CSGPolygon3D.MODE_PATH
	polygon.path_node = get_path()
	polygon.name = "CurvePolygon3D"
	add_child(polygon)

	
func create_custom_polygon(points: PackedVector2Array, mat: Material, 
						   smooth_faces: bool = false) -> void:
	polygon = CSGPolygon3D.new()
	polygon.polygon = points
	polygon.material = mat
	polygon.smooth_faces = smooth_faces
	
	
func create_cylinder_polygon(radius: float, segments: int, 
							 mat: Material, smooth_faces: bool = false) -> void:
	polygon = CSGPolygon3D.new()
	var poly2d = Figure2d.create_circle_polygon(radius, segments)
	polygon.polygon = poly2d.points
	polygon.material = mat
	polygon.smooth_faces = smooth_faces
	
	
func create_rect_polygon(size: Vector2, distance: Vector2 = Vector2.ZERO, 
						 mat: Material = StandardMaterial3D.new(), 
						 smooth_faces: bool = false) -> void:
	var points = PackedVector2Array([Vector2(0, 0) + distance, Vector2(size.x, 0) + distance, 
									 Vector2(size.x, size.y) + distance, Vector2(0, size.y) + distance])				
	polygon = CSGPolygon3D.new()
	polygon.polygon = points
	polygon.material = mat
	polygon.smooth_faces = smooth_faces
	

func create_curve(points: Array[Vector3]) -> void:	
	curve = Curve3D.new()
	for point in points:
		curve.add_point(point - global_position)
	
	
func create_quad_bezier(start: Vector3, mid: Vector3, end: Vector3) -> void:
	curve = Curve3D.new()
	
	curve.add_point(start, start, mid)
	curve.add_point(end, mid, end)

	
func create_line(from: Vector3, to: Vector3) -> void:
	curve = Curve3D.new()

	curve.add_point(from - global_position)
	curve.add_point(to - global_position)
	
	
func delete_curve() -> void:
	curve = null
	
