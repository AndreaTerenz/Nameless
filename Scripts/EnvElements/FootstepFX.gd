extends Node

@export var surf_name: String = "default"

var parent_body : StaticBody3D = null

func _ready() -> void:
	await get_tree().idle_frame
	
	if get_parent() is StaticBody3D:
		parent_body = get_parent()
		parent_body.set_meta("surf_name", surf_name)
	else:
		Console.Log.error("FootstepsFX node '%s' is not child of a StaticBody3D node!" % get_path())
