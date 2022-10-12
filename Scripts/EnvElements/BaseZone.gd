class_name BaseZone
extends Area3D

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

@export var one_shot: bool = true
@export var start_active: bool = true
@export var show: bool = false
@export var mask = 1 # (int, LAYERS_3D_PHYSICS)

@onready var debug_shape : MeshInstance3D = $MeshInstance3D

var active := true :
	get:
		return active # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_active
var contains_player := false
var zone_id := -1
var show_debug_shape : bool :
	get:
		return show_debug_shape # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of show_shape
var state = TARGET_STATE.NEVER_IN

func _ready() -> void:
	if debug_shape:
		show_shape(show)
	else:
		Console.Log.warn("TRIGGER '%s' HAS NO DEBUG SHAPE" % get_path())
		
	set_collision_layer_value(6, true)
	collision_mask = mask

# Already connected in Area3D
	connect("body_entered",Callable(self,"_on_body_entered"))
	connect("body_exited",Callable(self,"_on_body_exited"))
	connect("area_entered",Callable(self,"_on_area_entered"))
	connect("area_exited",Callable(self,"_on_area_exited"))
	
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
	if body in get_targets() and (not one_shot or state == TARGET_STATE.NEVER_IN):
		#Console.write(body)
		if one_shot:
			# If the target was detected and this is a one_shot zone,
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
	
func _on_area_entered(area: Area3D):
	_on_body_entered(area)

func _on_area_exited(area: Area3D):
	_on_body_exited(area)
