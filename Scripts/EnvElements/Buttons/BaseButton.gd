class_name Base_Button
extends Interactable

signal pressed
signal released

export(NodePath) var toggle_path

var pressed := false

onready var toggle: Togglable = get_node(toggle_path) as Togglable

func _ready() -> void:
	continuous = false

func press():
	emit_signal("pressed")
	pressed = true
	
func release():
	emit_signal("released")
	pressed = false
