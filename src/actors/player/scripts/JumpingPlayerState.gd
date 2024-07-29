class_name JumpingPlayerState extends PlayerMovementState


@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var SPEED : float = 5.0
@export var JUMP_VELOCITY : float = 6

@export_range(0.5, 1.0, 0.01) var INPUT_MULTIPLIER : float = 0.85 
# allows player move in the air


func enter() -> void:
	PLAYER.velocity.y += JUMP_VELOCITY
	ANIMATION.play("jumpStart")


func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED * INPUT_MULTIPLIER, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	WEAPON.sway_weapon(delta, false)
	
	if PLAYER.is_player_movable():
		if Input.is_action_just_released("jump"):
			if PLAYER.velocity.y > 0:
				PLAYER.velocity.y = PLAYER.velocity.y / 2.0
				
		if PLAYER.is_on_floor():
			ANIMATION.play("jumpEnd")
			transition.emit("IdlePlayerState")
			
		if PLAYER.velocity.y < -3.0 and !PLAYER.is_on_floor():
			transition.emit("FallingPlayerState")
		
