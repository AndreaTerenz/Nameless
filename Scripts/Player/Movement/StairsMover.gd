class_name StairsMover
extends PlayerMover


func compute_move(delta: float):
	player.stairs_chk.flipped = sign(player.head.rotation.x) < 0
	
	var dir = 0.0
	
	if Input.is_action_pressed("move_f") and player.stairs_chk.top_collision():
		dir = 1.0
	elif Input.is_action_pressed("move_b") and player.stairs_chk.bottom_collision():
		dir = -1.0
	
	return Vector3.UP * dir * sign(player.head.rotation.x) * player.h_speed
