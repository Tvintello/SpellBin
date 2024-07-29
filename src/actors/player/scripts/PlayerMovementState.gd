class_name PlayerMovementState

extends State


@export var TRANSITION_SPEED : float = 0.1


var PLAYER: Player
var ANIMATION: AnimationPlayer
var	WEAPON: WeaponController
var INTERACTION_RAY : RayCast3D
var is_transition : bool


func _ready() -> void:
	await owner.ready
	PLAYER = owner as Player
	ANIMATION = PLAYER.ANIMATIONPLAYER
	WEAPON = PLAYER.WEAPON_CONTROLLER
	INTERACTION_RAY = PLAYER.INTERACTION_RAY
	is_transition = false
	

func _process(_delta):
	if is_transition:
		PLAYER.CAMERA_CONTROLLER.position = lerp(PLAYER.CAMERA_CONTROLLER.position, PLAYER.INITIAL_CAMERA_POSITION, TRANSITION_SPEED)
