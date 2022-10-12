class_name CameraController
extends Camera3D

var std_fov := 65.0
var sprint_fov := 85.0
var zoom_fov := 30.0
var fov_tween_speed = .1
var zoomed := false
var sprinting := false
var target_fov := std_fov

@onready var gun_viewport = $SubViewportContainer
@onready var tween := $Tween

func toggle_sprint_fov(sprnt: bool):
	if not zoomed:
		sprinting = sprnt
		if sprinting:
			tween_fov(sprint_fov)
		else:
			tween_fov_to_std()
	
func tween_fov_to_std():
	if not tween.is_active():
		tween_fov(std_fov)
	
func tween_fov(trgt):
	if target_fov != trgt:
		target_fov = trgt
		tween.interpolate_property(self, "fov",\
			null, target_fov, .1,\
			Tween.TRANS_LINEAR,Tween.EASE_IN)
		tween.start()
	
func check_zoom():
	if Input.is_action_just_pressed("zoom"):
		zoomed = true
		tween_fov(zoom_fov)
	elif Input.is_action_just_released("zoom"):
		zoomed = false
		tween_fov_to_std()

func show_ui(show: bool):
	gun_viewport.visible = show
