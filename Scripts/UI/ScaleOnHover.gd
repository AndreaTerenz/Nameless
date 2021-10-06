class_name ScaleOnHover
extends Control

export(float, 1.0, 2.0, .05) var scaleFactor = 1.1

var tween : Tween
var base_scale : Vector2

func _ready() -> void:
	connect("mouse_entered", self, "_on_enter")
	connect("mouse_exited", self, "_on_exit")
	
	rect_pivot_offset = rect_size/2
	base_scale = rect_scale
	
	tween = Tween.new()
	call_deferred("add_child", tween)
	
func _on_enter() -> void:
	tween.interpolate_property(self, "rect_scale",
		rect_scale, base_scale * scaleFactor, .1,
		Tween.TRANS_QUART, Tween.EASE_OUT)
	tween.start()

func _on_exit() -> void:
	tween.interpolate_property(self, "rect_scale",
		rect_scale, base_scale, .1,
		Tween.TRANS_QUART, Tween.EASE_OUT)
	tween.start()
