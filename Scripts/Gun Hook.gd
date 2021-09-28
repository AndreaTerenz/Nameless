extends Spatial

export(bool) var swaying = false
export(float, .1, 12.0, .05) var sway_angle = 9.0
export(NodePath) var aim_pos_node
export(NodePath) var hide_pos_node

var base_rot: float = 0.0
var base_trans: Vector3 = Vector3.ZERO
var mouse_motion: Vector2 = Vector2.ZERO
var hidden: bool = false
var aiming: bool = false

onready var aiming_pos = get_node(aim_pos_node)
onready var hidden_pos = get_node(hide_pos_node)
onready var gun = $Gun

func _ready() -> void:
	base_rot = rotation.y
	base_trans = translation
	translation.z = base_trans.z + .4

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_motion = -event.relative
		
	if Input.is_action_just_pressed("aim"):
		aiming = true
	elif Input.is_action_just_released("aim"):
		aiming = false

func _physics_process(delta: float) -> void:
	var target_gun_pos: Vector3 = base_trans
	
	if aiming:
		rotation.y = base_rot
		target_gun_pos = aiming_pos.translation
	else:
		if hidden:
			target_gun_pos = hidden_pos.translation
		elif swaying:
			var angle_delta = deg2rad(sway_angle)*sign(-mouse_motion.x)
			
			rotation.y = lerp(rotation.y, base_rot + angle_delta, .1)
		
	translation = lerp(translation, target_gun_pos, .3)
		
	mouse_motion *= 0
