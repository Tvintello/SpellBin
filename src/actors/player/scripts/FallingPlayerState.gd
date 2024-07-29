class_name FallingPlayerState extends PlayerMovementState


@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var SPEED : float = 5.0
@export var JUMP_VELOCITY : float = 6

@export_range(0.5, 1.0, 0.01) var INPUT_MULTIPLIER : float = 0.85 
# allows player move in the air


func enter() -> void:
	ANIMATION.pause()


func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED * INPUT_MULTIPLIER, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	WEAPON.sway_weapon(delta, false)
	
	if PLAYER.is_on_floor():
		ANIMATION.play("jumpEnd")
		transition.emit("IdlePlayerState")
		
