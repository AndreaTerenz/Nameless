class_name Base_Button
extends Interactable

export(NodePath) var toggle_path
onready var toggle: Togglable = get_node(toggle_path) as Togglable

func _ready() -> void:
	continuous = false
