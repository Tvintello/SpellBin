class_name IdlePlayerState

extends PlayerMovementState


@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var SPEED : float = 5.0


func enter() -> void:
	if ANIMATION.is_playing() and ANIMATION.current_animation == "jumpEnd":
		await ANIMATION.animation_finished
		ANIMATION.pause()
	else:
		ANIMATION.pause()
		
		
func exit() -> void:
	WEAPON.remove_telekinesis()
		

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	WEAPON.sway_weapon(delta, true)
	
	if PLAYER.is_player_movable():
		if Input.is_action_just_pressed("crouch") and PLAYER.is_on_floor():
			transition.emit("CrouchingPlayerState")
		
		if PLAYER.velocity.length() > 0.0 and PLAYER.is_on_floor():
			transition.emit("WalkingPlayerState")
			
		if Input.is_action_just_pressed("jump") and PLAYER.is_on_floor():
			transition.emit("JumpingPlayerState")
			
		if PLAYER.velocity.y < -3.0 and !PLAYER.is_on_floor():
			transition.emit("FallingPlayerState")
			
	# Weapon section
	if WEAPON.disabled:
		return
			
	if Input.is_action_pressed("attack") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		WEAPON.attack()
	
	if Input.is_action_pressed("telekinesis") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		WEAPON.telekinesis()
	
	if Input.is_action_just_released("telekinesis"):
		WEAPON.remove_telekinesis()

	
		
	
