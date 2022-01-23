class_name StairsMover
extends PlayerMover

var std_mover_class = load("res://Scripts/Player/Movement/StandardMover.gd")

func _compute(delta: float):
	player.stairs_chk.flipped = sign(player.head.rotation.x) < 0
	
	var dir : Vector3 = Vector3.ZERO
	var mult : float = sign(player.head.rotation.x) * player.h_speed
	
	if player.inventory.is_overweight():
		mult *= player.speed_crouch_mult
	
	if Input.is_action_pressed("move_f") and player.stairs_chk.top_collision():
		dir = Vector3.UP
	elif Input.is_action_pressed("move_b") and player.stairs_chk.bottom_collision():
		dir = Vector3.DOWN
	
	return dir * mult
	
func get_next_mover():
	if player.mode == player.MODE.GAME:
		player.check_stairs()
		
		if not player.on_stairs:
			return std_mover_class.new()
			
	return null

func _to_string() -> String:
	return "STAIRS"
