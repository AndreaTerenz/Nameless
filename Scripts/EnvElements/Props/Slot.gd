class_name Slot
extends Area3D

signal activated

func _ready() -> void:
	connect("body_entered",Callable(self,"on_body_entered"))

func on_body_entered(body: Node):
	if body is Prop:
		disconnect("body_entered",Callable(self,"on_body_entered"))
		body.entered_slot(self)
		
		emit_signal("activated")
		_filled(body)

func _filled(p: Prop):
	pass
