class_name BaseDoor
extends Togglable

signal opened
signal closed

export(bool) var start_open := false

export(float, .01, 10.0, .01) var speed = 1.0
export(float, .2, 10.45, .05) var amount = 1.0
export(NodePath) var left_side_path
export(NodePath) var right_side_path

onready var left_side: DoorSide = get_node(left_side_path)
onready var right_side: DoorSide = get_node(right_side_path)

var is_open := false

func _ready() -> void:
	left_side.door_ready(self)
	right_side.door_ready(self)
	
	if start_open:
		open()

func open():
	emit_signal("opened")
	is_open = true
	_on_open()
	
func _on_open():
	pass
	
func close():
	emit_signal("closed")
	is_open = false
	_on_closed()
	
func _on_closed():
	pass
	
func _on_deactivated():
	close()
	
func _on_activated():
	open()
