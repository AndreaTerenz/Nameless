class_name PlayerMover
extends Node

var player = null
var current_speed: float = 0.0
var direction: Vector3 = Vector3.ZERO
var h_velocity: Vector3 = Vector3.ZERO
var h_acceleration: float = 0.0
var velocity: Vector3 = Vector3.ZERO
var gravity_direction: Vector3 = Vector3.ZERO

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
		gravity_direction = mov.gravity_direction
	else:
		current_speed = player.h_speed
		
	_setup()
	
func _setup():
	pass
	
func new_mode():
	return player.mode

func get_velocity(delta: float):
	velocity = _compute(delta)
	return velocity
	
func _compute(_delta: float) -> Vector3:
	return Vector3.ZERO

func stop():
	current_speed *= 0.0
	direction *= 0.0
	h_velocity *= 0.0
	h_acceleration *= 0.0
	velocity *= 0.0
	gravity_direction *= 0.0
