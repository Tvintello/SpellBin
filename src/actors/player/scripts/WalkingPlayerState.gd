class_name WalkingPlayerState

extends PlayerMovementState


@export var TOP_ANIMATION_SPEED : float = 2.2
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var SPEED : float = 5.0
@export var WEAPON_BOB_SPEED : float = 6.0
@export var WEAPON_BOB_H : float = 2.0
@export var WEAPON_BOB_V : float = 1.0


func enter() -> void:
	if ANIMATION.is_playing() and ANIMATION.current_animation == "jumpEnd":
		await ANIMATION.animation_finished
		ANIMATION.play("walking", -1.0, 1.0)
	else:
		ANIMATION.play("walking", -1.0, 1.0)
	
	
func exit() -> void:
	ANIMATION.speed_scale = 1.0	


func update(delta):
	# update вызывается в state_machine.gd
	
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	
	WEAPON.sway_weapon(delta, false)
	WEAPON.weapon_bob(delta, WEAPON_BOB_SPEED, WEAPON_BOB_H, WEAPON_BOB_V)
	
	if PLAYER.is_player_movable():
		set_animation_speed(sqrt(PLAYER.velocity.x**2 + PLAYER.velocity.z**2))
		if Input.is_action_pressed("sprint") and PLAYER.is_on_floor():
			transition.emit("SprintingPlayerState")
			
		if Input.is_action_pressed("crouch") and PLAYER.is_on_floor():
			transition.emit("CrouchingPlayerState")
			
		if Input.is_action_just_pressed("jump") and PLAYER.is_on_floor():
			transition.emit("JumpingPlayerState")
			
	if Input.is_action_pressed("attack") and not WEAPON.disabled:
		WEAPON.attack()
		
	if PLAYER.velocity.y < -3.0 and !PLAYER.is_on_floor():
		transition.emit("FallingPlayerState")
	
	if PLAYER.velocity.length() == 0.0:
		transition.emit("IdlePlayerState")
		

func physics_update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_collision()
	PLAYER.update_velocity()
	
	
func set_animation_speed(speed):
	var alpha = remap(speed, 0.0, SPEED, 0.0, 1.0)
	ANIMATION.speed_scale = lerp(0.0, TOP_ANIMATION_SPEED, alpha)
