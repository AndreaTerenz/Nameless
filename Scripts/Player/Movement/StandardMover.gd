class_name StandardMover
extends PlayerMover

var sprinting: bool = false
var crouching: bool = false
var bonked_head: bool = false
var crouch_released: bool = false

func _compute(delta: float):
	set_direction()
	
	var target_vel = direction * current_speed
	h_velocity = h_velocity.linear_interpolate(target_vel, h_acceleration * delta)
	
	check_sprinting()
	check_crouch()
	check_stairs(delta)
	
	set_gravity_vec(delta)
	
	return gravity_vec + h_velocity*Vector3(1,0,1)
	
func set_direction():
	direction *= 0.0
	
	# WHY -= ?????
	if Input.is_action_pressed("move_f"):
		direction -= Utils.local_direction(player, Vector3.FORWARD)
	elif Input.is_action_pressed("move_b"):
		direction -= Utils.local_direction(player, Vector3.BACK)
	
	if Input.is_action_pressed("move_l"):
		direction -= Utils.local_direction(player, Vector3.LEFT)
	elif Input.is_action_pressed("move_r"):
		direction -= Utils.local_direction(player, Vector3.RIGHT)
		
	direction = direction.normalized()
		
func set_gravity_vec(delta):
	h_acceleration = player.std_acceleration
	
	if not(player.is_on_floor()):
		if not(bonked_head) and player.roof_chk.is_colliding():
			gravity_vec *= 0.0
			bonked_head = true
		h_acceleration *= player.air_acc_factor
		var grav_delta : Vector3 = Vector3.DOWN * player.gravity_strength * delta
		gravity_vec += grav_delta
	else:
		bonked_head = false
		gravity_vec = -player.get_floor_normal() * player.gravity_strength
		
	var can_jump = (player.is_on_floor() or player.grnd_chk.is_colliding()) and not(crouching)
	if Input.is_action_just_pressed("jump") and can_jump:
			gravity_vec = Vector3.UP * player.jump_strength
			
func check_stairs(delta: float):
	if (player.leaving_stairs):
		var forw = -Utils.local_direction(player, Vector3.FORWARD)
		h_velocity = forw * current_speed 
		player.leaving_stairs = false
			
func check_crouch():
	if not(sprinting):
		if Input.is_action_just_pressed("crouch"):
			crouching = true
			player.head_anim.play("Crouch", -1, player.crouch_anim_mult)
		elif Input.is_action_just_released("crouch"):
			crouch_released = true
			
		if crouch_released and not(player.roof_chk.is_colliding()):
			crouch_released = false
			crouching = false
			player.head_anim.play("Crouch", -1, -player.crouch_anim_mult, true)
			
		current_speed = player.h_speed
		if crouching:
			current_speed *= player.speed_crouch_mult 

func check_sprinting():
	if not(crouching or \
			player.inventory.is_overweight()):
		if not(player.is_on_floor()):
			if Input.is_action_just_released("sprint"):
				sprinting = false 
		else:
			if Input.is_action_pressed("sprint"):
				sprinting = true
			elif Input.is_action_just_released("sprint"):
				sprinting = false 
				
			current_speed = player.h_speed
			if sprinting:
				current_speed *= player.speed_sprint_mult 
			
		player.camera.toggle_sprint_fov(sprinting)

func _to_string() -> String:
	return "STANDARD"
