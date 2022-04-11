class_name BaseZone
extends Area

enum TARGET_STATE {
	NEVER_IN,
	IS_IN,
	WAS_IN
}

signal target_entered(zone, target)
signal target_exited(zone, target)
signal state_changed(zone)
signal deactivated(zone)
signal reactivated(zone)

export(bool) var oneshot = true setget set_oneshot
export(bool) var show = false
export(int, LAYERS_3D_PHYSICS) var mask = 1
export(NodePath) var debug_shape_path = "MeshInstance"

var contains_player : bool = false
var zone_id := -1
var show_debug_shape : bool setget show_shape
var state = TARGET_STATE.NEVER_IN
var debug_shape : MeshInstance

func _ready() -> void:
	debug_shape = get_node(debug_shape_path) as MeshInstance
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
		emit_signal("reactivated", self)
	
func _on_body_entered(body: Node):
	if body in get_targets() and (not oneshot or state == TARGET_STATE.NEVER_IN):
		Console.write(body)
		if oneshot:
			# If the target was detected and this is a oneshot zone,
			# disable all collision detection
			Utils.toggle_area(self, false)
			emit_signal("deactivated", self)
			
		set_state(TARGET_STATE.IS_IN)
		contains_player = true
		emit_signal("target_entered", self, body)

func _on_body_exited(body: Node):
	if body in get_targets():
		set_state(TARGET_STATE.WAS_IN)
		contains_player = false
		emit_signal("target_exited", self, body)
		
func set_state(value):
	state = value
	emit_signal("state_changed", self)
	
func _on_area_entered(area: Area):
	_on_body_entered(area)

func _on_area_exited(area: Area):
	_on_body_exited(area)
