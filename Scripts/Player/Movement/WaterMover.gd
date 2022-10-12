class_name WaterMover
extends PlayerMover

var slowdown := 1/3.0
var bonked_head: bool = false

func _setup() -> void:
	gravity_direction *= slowdown

func _compute(delta: float):
	set_direction()
	
	var target_vel = direction * current_speed * slowdown
	h_velocity = h_velocity.lerp(target_vel, h_acceleration * delta)
	
	set_gravity_vec(delta)
	
	return gravity_direction + h_velocity*Vector3(1,0,1)
	
func set_direction():
	direction *= 0.0
	
	# WHY -= ?????
	if Input.is_action_pressed("move_f"):
		print(Utils.local_direction(player, Vector3.FORWARD))
		direction -= Utils.local_direction(player, Vector3.FORWARD)
	elif Input.is_action_pressed("move_b"):
		direction -= Utils.local_direction(player, Vector3.BACK)
	
	if Input.is_action_pressed("move_l"):
		direction -= Utils.local_direction(player, Vector3.LEFT)
	elif Input.is_action_pressed("move_r"):
		direction -= Utils.local_direction(player, Vector3.RIGHT)
		
	direction = direction.normalized()
		
func set_gravity_vec(delta):
	var sd = slowdown
	
	h_acceleration = player.std_acceleration * sd
	var grav = player.gravity_strength * sd

	if Input.is_action_pressed("jump"):
		gravity_direction = Vector3.ZERO
		
		if player.env_chk.is_fully_in_env(.05):
			gravity_direction = Vector3.UP * player.jump_strength * sd
	else:
		if not(player.is_on_floor()):
			if not(bonked_head) and player.roof_chk.is_colliding():
				gravity_direction *= 0.0
				bonked_head = true
			var grav_delta : Vector3 = Vector3.DOWN * grav * delta
			gravity_direction += grav_delta
		else:
			bonked_head = false
			gravity_direction = -player.get_floor_normal() * grav
			
func new_mode():
	if (player.environment != player.ENVIRONMENT.WATER):
		return player.MODE.GAME
			
	return player.mode

func _to_string() -> String:
	return "WATER"
