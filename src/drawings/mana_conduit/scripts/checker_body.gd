extends RigidBody3D


var collision_normal : Vector3


func _ready():
	contact_monitor = true
	max_contacts_reported = 1
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	freeze = true
	set_collision_layer_value(1, false)
	
	
func _integrate_forces(state: PhysicsDirectBodyState3D):
	if state.get_contact_count() > 0:
		collision_normal = state.get_contact_local_normal(0)
		
