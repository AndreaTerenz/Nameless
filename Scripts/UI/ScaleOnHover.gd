class_name ScaleOnHover
extends Control

export(float, 1.0, 2.0, .05) var scaleFactor = 1.1
export(NodePath) var target_node_path = ""

var target : Control = self
var tween : Tween
var base_scale : Vector2

func _ready() -> void:
	target = Utils.try_get_node(target_node_path, get_tree().root, self)
	
	target.connect("mouse_entered", self, "_on_enter")
	target.connect("mouse_exited", self, "_on_exit")
	
	target.rect_pivot_offset = target.rect_size/2
	
	base_scale = target.rect_scale
	
	tween = Tween.new()
	add_child(tween)
	
func _on_enter() -> void:
	tween.interpolate_property(target, "rect_scale",
		target.rect_scale, base_scale * scaleFactor, .1,
		Tween.TRANS_QUART, Tween.EASE_OUT)
	tween.start()

func _on_exit() -> void:
	tween.interpolate_property(target, "rect_scale",
		target.rect_scale, base_scale, .1,
		Tween.TRANS_QUART, Tween.EASE_OUT)
	tween.start()
