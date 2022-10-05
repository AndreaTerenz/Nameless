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

export(bool) var oneshot = true
export(bool) var start_active = true
export(bool) var show = false
export(int, LAYERS_3D_PHYSICS) var mask = 1

onready var debug_shape : MeshInstance = $MeshInstance

var active := true setget set_active
var contains_player := false
var zone_id := -1
var show_debug_shape : bool setget show_shape
var state = TARGET_STATE.NEVER_IN

func _ready() -> void:
	if debug_shape:
		show_shape(show)
	else:
		Console.Log.warn("TRIGGER '%s' HAS NO DEBUG SHAPE" % get_path())
		
	set_collision_layer_bit(6, true)
	collision_mask = mask

# Already connected in Area
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")
	
	_set_id()
	
	var grp = group()
	if grp != "":
		add_to_group(grp)
		
	set_active(start_active)

func show_shape(val):
	show_debug_shape = val
	if debug_shape:
		debug_shape.visible = show_debug_shape

func toggle_shape():
	show_debug_shape = not show_debug_shape
	if debug_shape:
		debug_shape.visible = show_debug_shape

func _set_id():
	zone_id = -1
	
func group():
	return ""
	
func get_targets() -> Array:
	# Enables detecting other objects
	return [Globals.player]

func set_active(value):
	active = value
	Utils.toggle_area(self, active)
	
	if active:
		emit_signal("reactivated", self)
		#Console.write_line("Activated zone: %s" % [get_path()])
	else:
		emit_signal("deactivated", self)
		#Console.write_line("Deactivated zone: %s" % [get_path()])
	
func _on_body_entered(body: Node):
	if body in get_targets() and (not oneshot or state == TARGET_STATE.NEVER_IN):
		#Console.write(body)
		if oneshot:
			# If the target was detected and this is a oneshot zone,
			# disable all collision detection
			set_active(false)
			
		set_state(TARGET_STATE.IS_IN)
		contains_player = true
		emit_signal("target_entered", self, body)
		_on_entered()
		
func _on_entered():
	pass

func _on_body_exited(body: Node):
	if body in get_targets():
		set_state(TARGET_STATE.WAS_IN)
		contains_player = false
		emit_signal("target_exited", self, body)
		_on_exited()
		
func _on_exited():
	pass
		
func set_state(value):
	state = value
	emit_signal("state_changed", self)
	
func _on_area_entered(area: Area):
	_on_body_entered(area)

func _on_area_exited(area: Area):
	_on_body_exited(area)
