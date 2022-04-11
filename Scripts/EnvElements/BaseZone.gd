class_name BaseZone
extends Area

enum TARGET_STATE {
	NEVER_IN,
	IS_IN,
	WAS_IN
}

signal target_entered(id)
signal target_exited(id)

export(bool) var oneshot = true setget set_oneshot
export(bool) var show = false
export(int, LAYERS_3D_PHYSICS) var mask = 1

var contains_player : bool = false
var zone_id := -1
var show_debug_shape : bool setget show_shape
var state = TARGET_STATE.NEVER_IN

onready var debug_shape : MeshInstance = $MeshInstance

func _ready() -> void:
	if debug_shape:
		show_shape(show)
	set_collision_layer_bit(6, true)
	collision_mask = mask
	
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")
	
	_set_id()
	
	var grp = group()
	if grp != "":
		add_to_group(grp)

func show_shape(val):
	show_debug_shape = val
	debug_shape.visible = val

func _set_id():
	zone_id = -1
	
func group():
	return ""
	
func get_targets() -> Array:
	# Enables detecting other objects
	return [Globals.player]
	
func set_oneshot(value):
	oneshot = value
	
	if not oneshot:
		Utils.toggle_area(self, true)
	
func _on_body_entered(body: Node):
	if body in get_targets() and (not oneshot or state == TARGET_STATE.NEVER_IN):
		Console.write(body)
		if oneshot:
			# If the target was detected and this is a oneshot zone,
			# disable all collision detection
			Utils.toggle_area(self, false)
			
		state = TARGET_STATE.IS_IN
		contains_player = true
		emit_signal("target_entered", zone_id)

func _on_body_exited(body: Node):
	if body in get_targets():
		state = TARGET_STATE.WAS_IN
		contains_player = false
		emit_signal("target_exited", zone_id)
	
func _on_area_entered(area: Area):
	_on_body_entered(area)

func _on_area_exited(area: Area):
	_on_body_exited(area)
