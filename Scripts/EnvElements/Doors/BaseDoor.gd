class_name BaseDoor
extends Togglable

signal opened
signal closed

export(bool) var start_open = false

export(float, .01, .90, .01) var speed = 0.2
export(float, .2, 10.45, .05) var amount = 0.9
export(NodePath) var left_side_path
export(NodePath) var right_side_path

onready var left_side: DoorSide = get_node(left_side_path)
onready var right_side: DoorSide = get_node(right_side_path)

func _ready() -> void:
	left_side.door_ready(self)
	right_side.door_ready(self)
	
	if start_open:
		open()

func open():
	emit_signal("opened")
	_on_open()
	
func _on_open():
	pass
	
func close():
	emit_signal("closed")
	_on_closed()
	
func _on_closed():
	pass
	
func _on_deactivated():
	close()
	
func _on_activated():
	open()
