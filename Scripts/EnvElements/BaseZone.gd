class_name BaseZone
extends Area

signal player_entered(id)
signal player_exited(id)

export(bool) var show = false
export(int, LAYERS_3D_PHYSICS) var mask = 1

var contains_player : bool = false
var zone_id := -1
var show_debug_shape : bool setget show_shape

onready var debug_shape : MeshInstance = $MeshInstance

func _ready() -> void:
	if debug_shape:
		show_shape(show)
	set_collision_layer_bit(6, true)
	collision_mask = mask
	
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")
	
	_set_id()

func show_shape(val):
	show_debug_shape = val
	debug_shape.visible = val

func _set_id():
	zone_id = -1
	
func _on_body_entered(body: Node):
	if body == Globals.player:
		contains_player = true
		emit_signal("player_entered", zone_id)

func _on_body_exited(body: Node):
	if body == Globals.player:
		contains_player = false
		emit_signal("player_exited", zone_id)
