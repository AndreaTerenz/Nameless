class_name BaseDoor
extends Togglable

export(float, .01, .90, .01) var speed = 0.2
export(float, .2, 1.45, .05) var amount = 0.9
export(NodePath) var left_side_path
export(NodePath) var right_side_path

onready var left_side: DoorSide = get_node(left_side_path)
onready var right_side: DoorSide = get_node(right_side_path)

func _ready() -> void:
	left_side.speed = speed
	left_side.amount = amount
	right_side.speed = speed
	right_side.amount = amount

func open():
	if active:
		left_side.open = true
		right_side.open = true
	
func close():
	if active:
		left_side.open = false
		right_side.open = false
	
func _on_deactivated():
	left_side.open = false
	right_side.open = false
