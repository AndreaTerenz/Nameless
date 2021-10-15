class_name Player
extends KinematicBody

enum MODE {
	GAME,
	CINEMATIC
}

export(float, 8, 30, .5) var h_speed = 10.0
export(float, 1.1, 3.5, .1) var speed_sprint_mult = 2.0
export(float, .1, .9, .05) var speed_crouch_mult = .4
export(float, .4, 3.0, .1) var crouch_anim_mult = 1.0
export(float, 10, 20, .5) var gravity_strength = 17.0
export(float, 6, 25, .5) var jump_strength = 10.0
export(float, .01, .2, .005) var mouse_sens_std = 0.1
export(float, .01, .9, .005) var zoom_mouse_sensitivity_factor = 0.33
export(float, 1, 10, .1) var std_acceleration = 6.0
export(float, .05, .2, .01) var fov_change_rate = .1
export(float, 60.0, 80.0, .5) var std_fov = 65.0
export(float, 80.0, 110.0, .5) var sprint_fov = 85.0
export(float, 20.0, 55.0, .5) var zoom_fov = 50.0
export(MODE) var start_mode = MODE.GAME

var mouse_sensitivity: float = .0
var current_speed: float = h_speed
var direction: Vector3 = Vector3.ZERO
var h_velocity: Vector3 = Vector3.ZERO
var h_acceleration: float = 0.0
var velocity: Vector3 = Vector3.ZERO
var gravity_vec: Vector3 = Vector3.ZERO
var bonked_head := false
var sprinting: bool = false
var crouching: bool = false
var crouch_released: bool = false
var leaving_stairs: bool = false
var on_stairs: bool = false

onready var mode = start_mode setget set_mode

onready var head = $Head
onready var head_anim = $Head/AnimationPlayer
onready var body = $Body
onready var camera : Camera = $Head/Camera
onready var gun_camera = $"Head/Camera/ViewportContainer/Viewport/Gun Camera"
onready var grnd_chk = $GroundCheck
onready var roof_chk = $Head/RoofCheck
onready var stairs_chk = $StairsChecks
onready var gun_hook = $"Head/Camera/ViewportContainer/Viewport/Gun Camera/Gun Hook"
onready var light = $"Head/Flashlight"

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_sensitivity = mouse_sens_std
	camera.fov_change_rate = fov_change_rate
	camera.std_fov = std_fov
	camera.sprint_fov = sprint_fov
	camera.zoom_fov = zoom_fov

func _input(event: InputEvent) -> void:
	if mode == MODE.CINEMATIC:
		return
	
	if Input.is_action_just_pressed("flashlight"):
		light.visible = !light.visible
	
	if not(on_stairs):
		if Input.is_action_just_pressed("zoom"):
			mouse_sensitivity = mouse_sens_std * zoom_mouse_sensitivity_factor
		elif Input.is_action_just_released("zoom"):
			mouse_sensitivity = mouse_sens_std
			
		camera.zoomed = (mouse_sensitivity != mouse_sens_std)
		gun_hook.hidden = (mouse_sensitivity != mouse_sens_std)
		
	if event is InputEventMouseMotion:
		var y_rot = deg2rad(-event.relative.x * mouse_sensitivity)
		
		rotate_y(y_rot)
		
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-80), deg2rad(80))
		
func _physics_process(delta: float) -> void:
	if mode == MODE.CINEMATIC:
		return
		
	gun_camera.global_transform = camera.global_transform
	check_stairs()
	
	if not(on_stairs):
		velocity = std_movement(delta)
	else:
		velocity = stairs_movement(delta)
	
	move_and_slide(velocity, Vector3.UP)

func set_mode(val):
	mode = val
	camera.show_ui(mode == MODE.GAME)
	gun_hook.hidden = (mode != MODE.GAME)

func translate_camera(offset: Vector3):
	var own_origin = transform.origin
	var cam_origin = camera.transform.origin
	
	var camera_body_delta = own_origin - cam_origin
	translation = offset - camera_body_delta
	
func check_stairs() -> void:
	if not(on_stairs):
		if is_on_floor() or not(leaving_stairs):
			stairs_chk.enabled = true
			on_stairs = stairs_chk.any_collisions()
			if on_stairs:
				gun_hook.hidden = true
				camera.set_sprinting_fov(false)
				sprinting = false
	else:
		if Input.is_action_just_pressed("jump"):
			gun_hook.hidden = false
			stairs_chk.enabled = false
			on_stairs = false
			leaving_stairs = true
	
func stairs_movement(delta: float):
	stairs_chk.flipped = sign(head.rotation.x) < 0
	
	var dir = 0.0
	
	if Input.is_action_pressed("move_f") and stairs_chk.top_collision():
		dir = 1.0
	elif Input.is_action_pressed("move_b") and stairs_chk.bottom_collision():
		dir = -1.0
	
	return Vector3.UP * dir * sign(head.rotation.x) * h_speed

func std_movement(delta: float):
	set_direction()
	
	check_sprinting()
	check_crouch()
		
	if not(leaving_stairs):
		h_velocity = h_velocity.linear_interpolate(direction * current_speed, h_acceleration * delta)
	else:
		h_velocity = direction * current_speed 
		leaving_stairs = false
	
	set_gravity_vec(delta)
	
	return gravity_vec + h_velocity*Vector3(1,0,1)
	
func adjust_for_crouch() -> void:
	current_speed = h_speed*speed_crouch_mult if crouching else h_speed
	
func set_gravity_vec(delta):
	if not(is_on_floor()):
		if roof_chk.is_colliding() and not(bonked_head):
			gravity_vec *= 0.0
			bonked_head = true
		h_acceleration = 0.0
		gravity_vec += Vector3.DOWN * gravity_strength * delta
	else:
		bonked_head = false
		h_acceleration = std_acceleration
		gravity_vec = -get_floor_normal() * gravity_strength
		
	var can_jump = (is_on_floor() or grnd_chk.is_colliding()) and not(crouching)
	if Input.is_action_just_pressed("jump") and can_jump:
			gravity_vec = Vector3.UP * jump_strength
			
func check_crouch():
	if not(sprinting):
		if Input.is_action_just_pressed("crouch"):
			crouching = true
			head_anim.play("Crouch", -1, crouch_anim_mult)
		elif Input.is_action_just_released("crouch"):
			crouch_released = true
			
		if crouch_released and not(roof_chk.is_colliding()):
			crouch_released = false
			crouching = false
			head_anim.play("Crouch", -1, -crouch_anim_mult, true)
			
		adjust_for_crouch()

func check_sprinting():
	if not(crouching):
		if not(is_on_floor()):
			if Input.is_action_just_released("sprint"):
				sprinting = false 
		else:
			if Input.is_action_pressed("sprint"):
				sprinting = true
			elif Input.is_action_just_released("sprint"):
				sprinting = false 
				
			current_speed = h_speed*speed_sprint_mult if sprinting else h_speed
			camera.set_sprinting_fov(sprinting)

func set_direction():
	direction *= 0.0
	
	if is_on_floor() or not(stairs_chk.enabled):
		if Input.is_action_pressed("move_f"):
			direction -= transform.basis.z
		elif Input.is_action_pressed("move_b"):
			direction += transform.basis.z
		
		if Input.is_action_pressed("move_l"):
			direction -= transform.basis.x
		elif Input.is_action_pressed("move_r"):
			direction += transform.basis.x
			
		direction = direction.normalized()
