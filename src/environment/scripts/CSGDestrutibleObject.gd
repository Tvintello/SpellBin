class_name CSGDestrutibleObject extends CSGCombiner3D

@onready var csg_mesh = $CSGMesh3D


func warp_shape(point: Vector3, radius: float, 
		rings: int, radial_segments: int) -> void:
			
	var sphere = CSGSphere3D.new()
	sphere.radius = radius
	sphere.rings = rings
	sphere.radial_segments = radial_segments
	sphere.operation = CSGShape3D.OPERATION_SUBTRACTION
	sphere.smooth_faces = false
	sphere.position = point
	
	add_child(sphere)
	create_mesh(sphere)
	
			
func create_mesh(warping_sphere: CSGSphere3D):
	# get the mesh from the CSGShape3D
	_update_shape()
	var orig_mesh = get_meshes()[1]
	var new_mesh : Mesh
	print("DONE ", get_child_count())
	
	# add each surface to new mesh using SurfaceTool, so we can generate an index array
	for i in orig_mesh.get_surface_count():
		var st = SurfaceTool.new()
		st.append_from(orig_mesh, i, Transform3D())
		st.set_material(orig_mesh.surface_get_material(i)) # materials aren't added by append_from for some reason
		st.index() # create the index array
		
		# create new mesh if first surface, otherwise add surface to existing mesh
		if i == 0: new_mesh = st.commit()
		else: st.commit(new_mesh)
		
	csg_mesh.mesh = new_mesh
	remove_child(warping_sphere)
	
