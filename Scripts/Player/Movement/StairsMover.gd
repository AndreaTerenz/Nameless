class_name StairsMover
extends PlayerMover

var ladders := []

func _compute(delta: float):
	var dir : Vector3 = Vector3.ZERO
	var mult : float = player.h_speed * \
		sign(clamp(player.head.rotation.x + deg2rad(12.0), -player.head_rot_limit, player.head_rot_limit))
	
	if player.inventory.is_overweight():
		mult *= player.speed_crouch_mult
	
	if Input.is_action_pressed("move_f"):
		dir = Vector3.UP
	elif Input.is_action_pressed("move_b"):
		dir = Vector3.DOWN
		
	player.leaving_stairs = Input.is_action_just_pressed("jump")
	
	return dir * mult
	
func new_mode():
	if player.mode == player.MODE.STAIRS and (ladders.empty() or player.leaving_stairs):
		return player.MODE.GAME
			
	return player.mode

func _to_string() -> String:
	return "STAIRS"
