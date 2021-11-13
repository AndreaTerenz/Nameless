class_name Player
extends KinematicBody

enum MODE {
	GAME,
	CINEMATIC,
	NOCLIP
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
var bonked_head: bool = false
var sprinting: bool = false
var leaving_stairs: bool = false
var on_stairs: bool = false

onready var mover = null
onready var mode = start_mode setget set_mode

onready var head = $Head
onready var head_anim = $Head/AnimationPlayer
onready var body = $Body
onready var foot = $Foot
onready var camera : CameraController = $Head/Camera
onready var gun_camera = $"Head/Camera/ViewportContainer/Viewport/Gun Camera"
onready var grnd_chk = $GroundCheck
onready var roof_chk = $Head/RoofCheck
onready var stairs_chk = $StairsChecks
onready var interact_chk = $Head/InteractRay
onready var hitbox = $Hitbox
onready var gun_hook = $"Head/Camera/ViewportContainer/Viewport/Gun Camera/Gun Hook"
onready var light = $"Head/Flashlight"

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_sensitivity = mouse_sens_std
	
	camera.fov_change_rate = fov_change_rate
	camera.std_fov = std_fov
	camera.sprint_fov = sprint_fov
	camera.zoom_fov = zoom_fov
	
	gun_hook.setup(camera.hud)
	
	set_mode(start_mode)

func _input(event: InputEvent) -> void:
	if mode == MODE.CINEMATIC:
		return
		
	if Input.is_action_just_pressed("noclip_toggle"):
		set_mode(MODE.NOCLIP if mode != MODE.NOCLIP else MODE.GAME)
	else:
		if Input.is_action_just_pressed("flashlight"):
			light.visible = !light.visible
		
		if not(on_stairs):
			mouse_sensitivity = mouse_sens_std
			
			camera.check_zoom()
			
			if camera.zoomed:
				mouse_sensitivity *= zoom_mouse_sensitivity_factor
			gun_hook.hidden = camera.zoomed
			
		if event is InputEventMouseMotion:
			var y_rot = deg2rad(-event.relative.x * mouse_sensitivity)
			
			rotate_y(y_rot)
			
			head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
			head.rotation.x = clamp(head.rotation.x, deg2rad(-80), deg2rad(80))
		
func _physics_process(delta: float) -> void:
	gun_camera.global_transform = camera.global_transform
	
	mover.compute_move(delta)
	move_and_slide(mover.velocity, Vector3.UP)
	
	if mode == MODE.GAME:
		check_stairs()
		
		if not(on_stairs) and mover is StairsMover:
			change_mover(StandardMover.new())
		elif on_stairs and mover is StandardMover:
			change_mover(StairsMover.new())

func set_mode(val):
	mode = val
	
	match (mode):
		MODE.GAME:
			camera.show_ui(true)
			gun_hook.hidden = false
			toggle_collisions(true)
			
			change_mover(StandardMover.new())
		MODE.CINEMATIC:
			camera.show_ui(false)
			gun_hook.hidden = true
			toggle_collisions(false)
			
			change_mover(PlayerMover.new())
		MODE.NOCLIP:
			camera.show_ui(true)
			camera.toggle_sprint_fov(false)
			gun_hook.hidden = false
			toggle_collisions(false)
			
			change_mover(NoClipMover.new())
			
func toggle_collisions(stat: bool):
	head.disabled = not(stat) #diobono
	body.disabled = not(stat) #diobono
	foot.disabled = not(stat)
	
	roof_chk.enabled = stat
	grnd_chk.enabled = stat
	stairs_chk.enabled = stat
	
	interact_chk.monitorable = stat
	interact_chk.monitoring = stat
	
	hitbox.monitorable = stat
	hitbox.monitoring = stat

func translate_camera(offset: Vector3):
	var own_origin = transform.origin
	var cam_origin = camera.transform.origin
	
	var camera_body_delta = own_origin - cam_origin
	translation = offset - camera_body_delta
	
func change_mover(new_mover: PlayerMover):
	if new_mover != mover:
		new_mover.setup(self)
		mover = new_mover
	
func check_stairs() -> void:
	if not(on_stairs) and (is_on_floor() or not(leaving_stairs)):
		stairs_chk.enabled = true
		on_stairs = stairs_chk.any_collisions()
		if on_stairs:
			gun_hook.hidden = true
			camera.toggle_sprint_fov(false)
			sprinting = false
	elif Input.is_action_just_pressed("jump"):
		gun_hook.hidden = false
		stairs_chk.enabled = false
		on_stairs = false
		leaving_stairs = true

func _on_killed() -> void:
	get_tree().reload_current_scene()
