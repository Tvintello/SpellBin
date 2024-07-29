class_name VoxelSpellGenerator extends VoxelGeneratorScript


# Change channel to SDF
const channel : int = VoxelBuffer.CHANNEL_SDF

func _generate_block(out_buffer : VoxelBuffer, origin_in_voxels : Vector3i, lod : int) -> void:
	for rz in out_buffer.get_size().z:
		for rx in out_buffer.get_size().x:
			var pos_world := Vector3(origin_in_voxels) + Vector3(rx << lod, 0, rz << lod)

			var height := 10.0 * (sin(pos_world.x * 0.1) + cos(pos_world.z * 0.1))

			for ry in out_buffer.get_size().y:
				pos_world.y = origin_in_voxels.y + (ry << lod)
				
				var signed_distance := pos_world.y - height

				out_buffer.set_voxel_f(signed_distance, rx, ry, rz, channel)
