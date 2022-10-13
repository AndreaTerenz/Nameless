class_name ScaleOnHover
extends Control

@export var scaleFactor = 1.1 # (float, 1.0, 2.0, .05)
@export var target_node_path: NodePath = ""

var target : Control = self
var base_scale : Vector2

func _ready() -> void:
	target = Utils.try_get_node(target_node_path, get_tree().root, self)
	
	target.connect("mouse_entered",Callable(self,"_on_enter"))
	target.connect("mouse_exited",Callable(self,"_on_exit"))
	
	target.pivot_offset = target.size/2
	
	base_scale = target.scale
	
func _on_enter() -> void:
	tween_scale()

func _on_exit() -> void:
	tween_scale(1.0)
		
func tween_scale(factor := scaleFactor):
	create_tween()\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_QUART)\
		.tween_property(target, "scale", base_scale * factor, .1)
	
