extends Node

export(String) var surf_name = "default"

var parent_body : StaticBody = null

func _ready() -> void:
	yield(get_tree(), "idle_frame")
	
	if get_parent() is StaticBody:
		parent_body = get_parent()
		parent_body.set_meta("surf_name", surf_name)
	else:
		Console.Log.error("FootstepsFX node '%s' is not child of a StaticBody node!" % get_path())
