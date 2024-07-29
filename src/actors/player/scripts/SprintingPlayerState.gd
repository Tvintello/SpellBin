class_name SprintingPlayerState extends PlayerMovementState


@export var TOP_ANIMATION_SPEED : float = 1.6
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var SPEED : float = 7.0
@export var WEAPON_BOB_SPEED : float = 12.0
@export var WEAPON_BOB_H : float = 4.0
@export var WEAPON_BOB_V : float = 2.0
@export var WALKING_THRESHOLD : float = 2.0


func enter() -> void:
	is_transition = false
	ANIMATION.play("sprinting", -1.0, 1.0)


func exit() -> void:
	is_transition = true

	
func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	PLAYER.update_collision()
	
	WEAPON.sway_weapon(delta, false)
	WEAPON.weapon_bob(delta, WEAPON_BOB_SPEED, WEAPON_BOB_H, WEAPON_BOB_V)
	
	if PLAYER.is_player_movable():
		set_animation_speed(sqrt(PLAYER.velocity.x**2 + PLAYER.velocity.z**2))
		
		if Input.is_action_just_released("sprint"):
			transition.emit("WalkingPlayerState")
			
		if Input.is_action_just_pressed("jump") and PLAYER.is_on_floor():
			transition.emit("JumpingPlayerState")
			
		if PLAYER.velocity.y < -3.0 and !PLAYER.is_on_floor():
			transition.emit("FallingPlayerState")
	
	if PLAYER.velocity.length() < WALKING_THRESHOLD and PLAYER.is_on_floor():
		transition.emit("WalkingPlayerState")

	
func set_animation_speed(speed):
	var alpha = remap(speed, 0.0, SPEED, 0.0, 1.0)
	ANIMATION.speed_scale = lerp(0.0, TOP_ANIMATION_SPEED, alpha)

