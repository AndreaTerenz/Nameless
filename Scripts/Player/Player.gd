class_name Player
extends KinematicBody

signal mode_changed(new_mode)
signal mover_changed(new_mov)
signal env_changed(new_env)

enum ENVIRONMENT {
	NONE,
	NORMAL,
	WATER
}

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
export(float, 10.0, 90.0, .01) var head_rot_limit = 80.0
export(float, 1, 10, .1) var std_acceleration = 6.0
export(float, .05, .2, .01) var fov_tween_speed = .1
export(float, 60.0, 80.0, .5) var std_fov = 65.0
export(float, 80.0, 110.0, .5) var sprint_fov = 85.0
export(float, 20.0, 55.0, .5) var zoom_fov = 50.0
export(float, 1.0, 100.0, .1) var hitbox_start_hp = 100.0
export(MODE) var start_mode = MODE.GAME
export(bool) var get_fall_damage = true

var mouse_sensitivity: float = .0
var bonked_head: bool = false
var sprinting: bool = false
var leaving_stairs: bool = false
var on_stairs: bool = false
var others_dict: Dictionary = {
	Globals.GROUPS.ENEMIES: 0,
	Globals.GROUPS.FRIENDLY: 0,
	Globals.GROUPS.NEUTRAL: 0,
}
var compass_range := 0.0

onready var mover = null
onready var mode = -1 setget set_mode
onready var environment = ENVIRONMENT.NONE setget set_env

onready var inventory: Inventory = $Inventory
onready var head = $Head
onready var head_anim = $Head/AnimationPlayer
onready var body = $Body
onready var foot = $Foot
onready var camera : CameraController = $Head/Camera
onready var water_hemisphere = $"Head/Camera/Water Effect 3D"
onready var env_chk = $"Head/Env Check"
onready var hud = $Head/Camera/ViewportContainer/Hud
onready var compass = $Head/Camera/ViewportContainer/Hud/Compass
onready var gun_camera = $"Head/Camera/ViewportContainer/Viewport/Gun Camera"
onready var grnd_chk = $Foot/GroundCheck
onready var roof_chk = $Head/RoofCheck
onready var stairs_chk = $StairsChecks
onready var interact_chk = $Head/InteractRay
onready var aim_ray = $Head/AimRay
onready var hitbox : Hitbox = $Hitbox
onready var others_chck = $OthersDetection
onready var gun_hook = $"Head/Camera/ViewportContainer/Viewport/Gun Camera/Gun Hook"
onready var light = $"Head/Flashlight"

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	mouse_sens_std *= Settings.get_value(Settings.CONTROLS, Settings.MOUSE_SENS)
	mouse_sensitivity = mouse_sens_std
	
	camera.fov_tween_speed = fov_tween_speed
	camera.std_fov = std_fov
	camera.sprint_fov = sprint_fov
	camera.zoom_fov = zoom_fov
	
	compass_range = (others_chck.get_child(0) as CollisionShape).shape.radius + 5
	
	hitbox.health = hitbox_start_hp
	
	grnd_chk.debug_ignore_dmg = not get_fall_damage
	
	set_mode(start_mode)
	
	Globals.set_player(self)

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
			var event_rel : Vector2 = Utils.vec2_deg2rad(-event.relative * mouse_sensitivity)
			var invert_y = -Utils.bool_to_sign(Settings.get_value(Settings.CONTROLS, Settings.INVERT_Y))
			var y_rot = event_rel.x
			
			rotate_y(y_rot)
			head.rotate_x(event_rel.y * invert_y)
			
			var hrl = deg2rad(head_rot_limit)
			head.rotation.x = clamp(head.rotation.x, -hrl, hrl)
		
func _physics_process(delta: float) -> void:
	gun_camera.global_transform = camera.global_transform
	
	move_and_slide(mover.get_velocity(delta), Vector3.UP)
	
	change_mover(mover.get_next_mover())

func set_mode(val):
	if mode != val:
		mode = val
	
		emit_signal("mode_changed", mode)
		
		match (mode):
			MODE.GAME:
				camera.show_ui(true)
				gun_hook.hidden = false
				toggle_collisions(true)
				
				change_mover(StandardMover.new())
				
				restore_env()
			MODE.CINEMATIC:
				camera.show_ui(false)
				camera.toggle_sprint_fov(false)
				gun_hook.hidden = true
				toggle_collisions(false)
				
				set_env(ENVIRONMENT.NONE)
				change_mover(PlayerMover.new())
			MODE.NOCLIP:
				camera.show_ui(true)
				camera.toggle_sprint_fov(false)
				gun_hook.hidden = false
				toggle_collisions(false)
				
				change_mover(NoClipMover.new())
				
				restore_env()
				
func set_env(val):
	if environment != val:
		if environment != -1:
			emit_signal("env_changed", val)
			
		environment = val
		
		match(environment):
			ENVIRONMENT.WATER:
				grnd_chk.enabled = false
			ENVIRONMENT.NORMAL:
				grnd_chk.enabled = true
				
func restore_env():
	var old = environment
	environment = -1
	set_env(old)
			
func mode_str():
	match (mode):
		MODE.GAME:
			return "GAME"
		MODE.CINEMATIC:
			return "CINEMATIC"
		MODE.NOCLIP:
			return "NOCLIP"
			
func toggle_collisions(stat: bool):
	head.disabled = not(stat) #diobono
	body.disabled = not(stat) #diobono
	foot.disabled = not(stat) #diobono
	
	roof_chk.enabled = stat
	grnd_chk.enabled = stat
	stairs_chk.enabled = stat
	
	interact_chk.monitorable = stat
	interact_chk.monitoring = stat
	
	hitbox.monitorable = stat
	hitbox.monitoring = stat
	
	others_chck.monitoring = stat
	others_chck.monitorable = stat
	
	aim_ray.enabled = stat

func change_mover(new_mover: PlayerMover):
	if new_mover == null:
		return
	if new_mover != mover:
		new_mover.setup(self)
		mover = new_mover
		emit_signal("mover_changed", mover)
	
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
	Globals._restart()

func get_other_type(_other: Node):
	var other = _other as CollisionObject
	if other:
		var ls = [Globals.GROUPS.ENEMIES, Globals.GROUPS.FRIENDLY]
		
		for l in ls:
			if Globals.get_layer_bit_in_object(other, Globals.group_layers[l]):
				return l
			
	return Globals.GROUPS.NEUTRAL

func _on_other_detected(body: Node) -> void:
	var type = get_other_type(body)
	others_dict[type] += 1
	compass.add_target(body, type)


func _on_other_lost(body: Node) -> void:
	var type = get_other_type(body)
	others_dict[type] -= 1
	compass.remove_target(body)

func _on_entered_env(area: Area) -> void:
	if (Globals.get_layer_bit_in_object(area, "Water")):
		set_env(ENVIRONMENT.WATER)


func _on_exited_env(area: Area) -> void:
	set_env(ENVIRONMENT.NORMAL)
