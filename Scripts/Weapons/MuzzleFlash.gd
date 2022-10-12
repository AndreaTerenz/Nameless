class_name MuzzleFlash
extends MeshInstance3D

@export var visible_time: float = .1

var timer := Timer.new()

func _ready() -> void:
	visible = false
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	randomize()
	
	add_child(timer)
	timer.connect("timeout",Callable(self,"_on_timeout"))
	timer.one_shot = true

func show():
	if timer.is_stopped():
		scramble()
		timer.start(visible_time)
		visible = true

func _on_timeout() -> void:
	visible = false
	rotation *= 0

func scramble():
	rotate_x(randf_range(-PI/4, PI/4))
