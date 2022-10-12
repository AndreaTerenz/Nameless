class_name Prop
extends RigidBody3D

signal picked_up(by)
signal dropped(by)
signal entered_slot
signal launched(by, strength)

@export var mesh_ref: NodePath
@export var explode_enabled: bool = true
@export var grab_enabled: bool = true

var mesh : MeshInstance3D = null
var tween : Tween = Tween.new()
var holder : Node3D = null
var entered_slot()_func := ""
var initial_parent : Node

var rotate_to_holder := false

func _ready() -> void:
	add_to_group(Globals.PROP_GRP)
	if explode_enabled:
		add_to_group(Globals.EXPL_PROP_GRP)
		
	var m = get_node(mesh_ref)
	mesh = m
	
	initial_parent = get_parent()
	collision_layer = 0
	collision_mask = 0
	Utils.set_layer_bit_in_object(self, "Props")
	Utils.set_mask_bits_in_object(self, ["Props", "Env", "Player"])
	
	add_child(tween)
	sleeping = true

func _process(delta: float) -> void:
	if rotate_to_holder:
		var wrotation = Utils.lerp_rot_towards(self, holder, 8.0*delta)

		global_transform = Transform3D(Basis(wrotation), global_transform.origin)
		
		rotate_to_holder = (wrotation.length() > 0)

func picked_up(by: Node, distance := 1.0, on_entered_slot := "on_entered_slot"):
	if grab_enabled:
		emit_signal("picked_up", by)
		
		mode = RigidBody3D.FREEZE_MODE_KINEMATIC
		Console.write_line("Prop " + name + " was PICKED UP")
		holder = by
		entered_slot_func = on_entered_slot
		connect("entered_slot",Callable(holder,entered_slot_func))
		
		var old_pos := Utils.get_global_pos(self)
		var holder_pos := Utils.get_global_pos(holder)
		
		Utils.transfer_node(self, holder)
		Utils.toggle_mask_bit_in_object(self, "Player")

		var d = old_pos.distance_to(holder_pos)
		var start_pos : Vector3 = holder.to_local(old_pos)
		var end_pos := Vector3.BACK * min(d, distance)
		
		rotate_to_holder = true
		
		tween.interpolate_property(self, "transform:origin", start_pos, end_pos, .1, Tween.TRANS_EXPO, Tween.EASE_OUT)
		tween.start()
		
		_on_picked_up()
		
func _on_picked_up():
	pass
	
func dropped(mouse_moving := true):
	Console.write_line("Prop " + name + " was DROPPED")
	_release()
	
	emit_signal("dropped", holder)
	
	if mouse_moving:
		var mouse_speed := Input.get_last_mouse_velocity()
		# finnicky
		var dir_x := Utils.local_direction(self, Vector3.RIGHT) * mouse_speed.x
		var dir_y := Utils.local_direction(self, Vector3.UP) * mouse_speed.y
		var push = ((dir_x + dir_y) * .01).limit_length(16.0)

		apply_central_impulse(push)
		
	holder = null
	
	_on_dropped()
	
func _on_dropped():
	pass

func launched(strength, forward_origin: Node3D = holder):
	Console.write_line("Prop " + name + " was LAUNCHED")
	_release()
	
	emit_signal("launched", holder, strength) 
	#holder = null
	apply_central_impulse(Utils.local_direction(forward_origin, Vector3.FORWARD) * strength)
	holder = null
	
	_on_launched()
	
func _on_launched():
	pass

func _release():
	mode = RigidBody3D.MODE_RIGID
	sleeping = false
	
	tween.stop_all()
	rotate_to_holder = false
	
	disconnect("entered_slot",Callable(holder,entered_slot_func))
	
	var old_pos = Utils.get_global_pos(self)
	var old_rot = Utils.get_global_rotation(self)
	Utils.transfer_node(self, initial_parent)
	Utils.toggle_mask_bit_in_object(self, "Player")
	Utils.set_global_pos(self, old_pos)
	transform.basis = old_rot
	
func entered_slot(s):
	emit_signal("entered_slot")
	
	tween.stop_all()
	rotate_to_holder = false
	
	disconnect("entered_slot",Callable(holder,entered_slot_func))
	holder = null
	
	grab_enabled = false
	explode_enabled = false
	
	if is_in_group(Globals.EXPL_PROP_GRP):
		remove_from_group(Globals.EXPL_PROP_GRP)
	
	mode = RigidBody3D.FREEZE_MODE_STATIC
	
	Utils.transfer_node(self, s)
	position *= 0.0
	rotation *= 0.0

func push(from: Vector3, force: float):
	if not holder and explode_enabled:
		sleeping = false
		var dir = from.direction_to(Utils.get_global_pos(self))
		apply_central_impulse(dir * force)
