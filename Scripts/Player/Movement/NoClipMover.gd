class_name NoClipMover
extends PlayerMover

var sprinting: bool = false
var crouching: bool = false
var bonked_head: bool = false
var crouch_released: bool = false

func setup(pl):
	read_prev_mover = false
	.setup(pl)

func compute_move(delta: float):
	set_direction()
	
	return direction * player.h_speed * player.speed_sprint_mult
	
func set_direction():
	var basis : Basis = player.transform.basis
	direction *= 0.0
	
	if Input.is_action_pressed("move_f"):
		direction -= basis.z
	elif Input.is_action_pressed("move_b"):
		direction += basis.z
	
	if Input.is_action_pressed("move_l"):
		direction -= basis.x
	elif Input.is_action_pressed("move_r"):
		direction += basis.x
		
	if Input.is_action_pressed("jump"):
		direction += basis.y
	elif Input.is_action_pressed("noclip_descend"):
		direction -= basis.y
		
	direction = direction.normalized()
