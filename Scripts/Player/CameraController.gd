class_name CameraController
extends Camera

var std_fov = 65.0
var sprint_fov = 85.0
var zoom_fov = 50.0
var fov_change_rate = .1
var zoomed: bool = false
var sprinting: bool = false
var target_fov: float = std_fov

onready var gun_viewport = $ViewportContainer
#onready var hud = $Hud

func toggle_sprint_fov(sprnt: bool):
	sprinting = sprnt
		
func _process(delta: float) -> void:
	target_fov = std_fov
	
	if zoomed:
		target_fov = zoom_fov
	elif sprinting:
		target_fov = sprint_fov
	
	fov = lerp(fov, target_fov, fov_change_rate)
	
func check_zoom():
	if Input.is_action_just_pressed("zoom"):
		zoomed = true
	elif Input.is_action_just_released("zoom"):
		zoomed = false

func show_ui(show: bool):
	gun_viewport.visible = show
