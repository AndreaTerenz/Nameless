class_name StandardMover
extends PlayerMover

enum CROUCH_STATE {
	ACTIVE,
	RELEASED,
	INACTIVE
}

var sprinting: bool = false
var crouching: bool = false
var crouch_state = CROUCH_STATE.INACTIVE
var bonked_head: bool = false
var crouch_released: bool = false
var sprint_released: bool = false

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
	var prsd : Dictionary = {
		"f" : Input.is_action_pressed("move_f"),
		"b" : Input.is_action_pressed("move_b"),
		"l" : Input.is_action_pressed("move_l"),
		"r" : Input.is_action_pressed("move_r"),
	}
	# if I'm pressing at least one key and I'm on the floor
	# then reset the direction vector
	if prsd.values().find(true) != -1 or player.is_on_floor():
		direction *= 0.0
	
	# WHY -= ?????
	if prsd["f"]:
		direction -= Utils.local_direction(player, Vector3.FORWARD)
	elif prsd["b"]:
		direction -= Utils.local_direction(player, Vector3.BACK)
	
	if prsd["l"]:
		direction -= Utils.local_direction(player, Vector3.LEFT)
	elif prsd["r"]:
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
		
	if Input.is_action_just_pressed("jump") and can_jump():
			direction *= 0.0
			gravity_vec = Vector3.UP * player.jump_strength

func can_jump():
	return player.touching_floor() and crouch_state == CROUCH_STATE.INACTIVE

func check_stairs(delta: float):
	if (player.leaving_stairs):
		var forw = -Utils.local_direction(player, Vector3.FORWARD)
		h_velocity = forw * current_speed 
		player.leaving_stairs = false
			
func check_crouch():
	if not(sprinting):
		match crouch_state:
			CROUCH_STATE.INACTIVE:
				current_speed = player.h_speed
				if Input.is_action_just_pressed("crouch"):
					if not(player.roof_chk.is_colliding()):
						crouch_state = CROUCH_STATE.ACTIVE
						player.head_anim.play("Crouch", -1, player.crouch_anim_mult)
			CROUCH_STATE.ACTIVE:
				current_speed = player.h_speed * player.speed_crouch_mult
				if Input.is_action_just_pressed("crouch"):
					crouch_state = CROUCH_STATE.RELEASED
			CROUCH_STATE.RELEASED:
				if Input.is_action_just_pressed("crouch"):
					crouch_state = CROUCH_STATE.ACTIVE
				elif not(player.roof_chk.is_colliding()):
					crouch_state = CROUCH_STATE.INACTIVE
					player.head_anim.play("Crouch", -1, -player.crouch_anim_mult, true)

func check_sprinting():
	if crouch_state == CROUCH_STATE.INACTIVE and not player.inventory.is_overweight():
		
		var just_pressed := Input.is_action_just_pressed("sprint")
		
		if sprinting:
			if player.is_on_floor():
				if direction == Vector3.ZERO or just_pressed or sprint_released:
					sprinting = false
					sprint_released = false
			elif just_pressed:
				sprint_released = true
		else:
			if player.is_on_floor() and direction != Vector3.ZERO and just_pressed:
				sprinting = true
		
		current_speed = player.h_speed
		if sprinting:
			current_speed *= player.speed_sprint_mult 
			
		player.camera.toggle_sprint_fov(sprinting)

func _to_string() -> String:
	return "STANDARD"
