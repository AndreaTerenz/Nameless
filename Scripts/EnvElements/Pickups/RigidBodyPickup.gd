class_name RigidBodyPickup
extends RigidBody

signal picked_up(by)
signal dropped(by)
signal launched(by, strength)

var enabled := true
var tween : Tween = Tween.new()
var holder : Spatial = null
var initial_parent : Node

func _ready() -> void:
	initial_parent = get_parent()
	collision_layer = 0
	collision_mask = 0
	Utils.set_layer_bit_in_object(self, "RBPickups")
	Utils.set_mask_bits_in_object(self, ["RBPickups", "Env", "Player"])
	
	add_child(tween)

func picked_up(by: Node, distance := 1.0):
	emit_signal("picked_up", by)
	
	mode = RigidBody.MODE_KINEMATIC
	#Console.write_line("RBPickup " + name + " switched to MODE_KINEMATIC")
	holder = by
	
	var old_pos := Utils.get_global_pos(self)
	Utils.transfer_node(self, holder)
	Utils.toggle_mask_bit_in_object(self, "Player")
	
	var d = old_pos.distance_to(Utils.get_global_pos(holder))
	var start_pos : Vector3 = holder.to_local(old_pos)
	var end_pos := Vector3.FORWARD * min(d, distance)
	
	tween.interpolate_property(self, "transform:origin", start_pos, end_pos, .1, Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.interpolate_property(self, "rotation", null, Vector3.ZERO, .1, Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.start()
	
func dropped():
	emit_signal("dropped", holder)
	#Console.write_line("Dropped RBPickup " + name)
	_release()

func launched(strength, forward_origin: Spatial = holder):
	_release(false)
	
	emit_signal("launched", holder, strength) 
	#holder = null
	apply_central_impulse(-Utils.get_dir_vector(forward_origin, Vector3.AXIS_Z) * strength)

func _release(wipe_holder := true):
	mode = RigidBody.MODE_RIGID
	sleeping = false
	#Console.write_line("RBPickup " + name + " switched to MODE_RIGID")
	if wipe_holder:
		pass#holder = null
	
	tween.stop_all()
	
	var old_pos = Utils.get_global_pos(self)
	var old_rot = Utils.get_global_rotation(self)
	Utils.transfer_node(self, initial_parent)
	Utils.toggle_mask_bit_in_object(self, "Player")
	Utils.set_global_pos(self, old_pos)
	transform.basis = old_rot
