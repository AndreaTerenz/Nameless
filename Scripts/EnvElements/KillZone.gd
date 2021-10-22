class_name KillZone
extends Area

export(NodePath) var shape_path = "MeshInstance"
export(bool) var visible_shape = false
export(int, LAYERS_3D_PHYSICS) var mask = 1

var show_debug_shape : bool setget show_shape

onready var debug_shape : MeshInstance = get_node(shape_path)

func show_shape(val):
	show_debug_shape = val
	(debug_shape).visible = val

func _ready() -> void:
	if debug_shape:
		show_shape(visible_shape)
	set_collision_layer_bit(6, true)
	collision_mask = mask
