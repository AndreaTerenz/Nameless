class_name StairsMover
extends PlayerMover

var ladders := []

func _compute(_delta: float):
	var dir : Vector3 = Vector3.ZERO
	var hrl = player.head_rot_limit
	var r = clamp(player.head.rotation.x + deg2rad(12.0), -hrl, hrl)
	var mult : float = player.h_speed * sign(r)
	
	if player.inventory.is_overweight():
		mult *= player.speed_crouch_mult
	
	if Input.is_action_pressed("move_f"):
		dir = Vector3.UP
	elif Input.is_action_pressed("move_b"):
		dir = Vector3.DOWN
		
	player.leaving_stairs = Input.is_action_just_pressed("jump")
	
	return dir * mult
	
func add_ladder(l: Spatial):
	ladders.append(l)
	
	if len(ladders) == 1:
		var snap_to = l.get_snap_for_obj(player)
		
		var tween = create_tween()
		tween.tween_property(player, "global_transform:origin", snap_to, .1)

func remove_ladder(l):
	ladders.erase(l)
	
func new_mode():
	if player.mode == player.MODE.STAIRS and (ladders.empty() or player.leaving_stairs):
		return player.MODE.GAME
			
	return player.mode

func _to_string() -> String:
	return "STAIRS"
