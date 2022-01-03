class_name StandardMover
extends PlayerMover

var sprinting: bool = false
var crouching: bool = false
var bonked_head: bool = false
var crouch_released: bool = false

func _compute(delta: float):
	set_direction()
	
	check_sprinting()
	check_crouch()
		
	if not(player.leaving_stairs):
		h_velocity = h_velocity.linear_interpolate(direction * current_speed, h_acceleration * delta)
	else:
		h_velocity = direction * current_speed 
		player.leaving_stairs = false
	
	set_gravity_vec(delta)
	
	return gravity_vec + h_velocity*Vector3(1,0,1)
	
func set_direction():
	direction *= 0.0
	
	var basis : Basis = player.transform.basis
	
	if player.is_on_floor() or not(player.stairs_chk.enabled):
		if Input.is_action_pressed("move_f"):
			direction -= basis.z
		elif Input.is_action_pressed("move_b"):
			direction += basis.z
		
		if Input.is_action_pressed("move_l"):
			direction -= basis.x
		elif Input.is_action_pressed("move_r"):
			direction += basis.x
			
		direction = direction.normalized()
		
func set_gravity_vec(delta):
	if not(player.is_on_floor()):
		if player.roof_chk.is_colliding() and not(bonked_head):
			gravity_vec *= 0.0
			bonked_head = true
		h_acceleration = 0.0
		gravity_vec += Vector3.DOWN * player.gravity_strength * delta
	else:
		bonked_head = false
		h_acceleration = player.std_acceleration
		gravity_vec = -player.get_floor_normal() * player.gravity_strength
		
	var can_jump = (player.is_on_floor() or player.grnd_chk.is_colliding()) and not(crouching)
	if Input.is_action_just_pressed("jump") and can_jump:
			gravity_vec = Vector3.UP * player.jump_strength
			
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
	if not(crouching or player.inventory.is_overweight()):
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
