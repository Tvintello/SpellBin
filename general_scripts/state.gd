class_name State
extends Node


@export var disabled : bool = false

signal transition(new_state_name: StringName)


func enter() -> void:
	pass
	
func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass
	
