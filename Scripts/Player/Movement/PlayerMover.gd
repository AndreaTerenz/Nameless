class_name PlayerMover
extends Node

var player = null
var current_speed: float = 0.0
var direction: Vector3 = Vector3.ZERO
var h_velocity: Vector3 = Vector3.ZERO
var h_acceleration: float = 0.0
var velocity: Vector3 = Vector3.ZERO
var gravity_vec: Vector3 = Vector3.ZERO

var read_prev_mover := true

func setup(pl) -> void:
	player = pl
	
	if read_prev_mover and player.mover != null:
		var mov = player.mover
		
		current_speed = mov.current_speed
		direction = mov.direction
		h_velocity = mov.h_velocity
		h_acceleration = mov.h_acceleration
		velocity = mov.velocity
		gravity_vec = mov.gravity_vec
	else:
		current_speed = player.h_speed

func compute_move(delta: float):
	pass
