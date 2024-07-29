extends StateMachine


@export var disabled = false


func _process(delta):
	if disabled or CURRENT_STATE.disabled:
		return
	CURRENT_STATE.update(delta)
	Global.debug.add_property("Current state", CURRENT_STATE.name, 1)
	
	
func _physics_process(delta):
	if disabled or CURRENT_STATE.disabled:
		return
	CURRENT_STATE.physics_update(delta)
