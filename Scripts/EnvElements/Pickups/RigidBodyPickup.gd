class_name RigidBodyPickup
extends RigidBody

signal picked_up(by)
signal dropped(by)
signal launched(by, strength)

var enabled := true

var holder : Node = null
var initial_parent : Node

func _ready() -> void:
	initial_parent = get_parent()

func picked_up(by: Node, new_parent : Node):
	emit_signal("picked_up", by)
	
	mode = RigidBody.MODE_KINEMATIC
	Console.write_line("RBPickup " + name + " switched to MODE_KINEMATIC")
	holder = by
	
	Utils.transfer_node(self, new_parent)
	transform.origin *= 0.0
	
func dropped():
	emit_signal("dropped", holder)
	Console.write_line("Dropped RBPickup " + name)
	_release()

func launched(forward_origin: Spatial = null, strength := 10.0):
	emit_signal("launched", holder, strength)
	_release()
	
	if not forward_origin:
		forward_origin = holder
	apply_central_impulse(-Utils.get_dir_vector(forward_origin, Vector3.AXIS_Z) * strength)

func _release():
	mode = RigidBody.MODE_RIGID
	sleeping = false
	Console.write_line("RBPickup " + name + " switched to MODE_RIGID")
	holder = null
	
	var old_pos = Utils.get_global_pos(self)
	Utils.transfer_node(self, initial_parent)
	self.transform.origin = old_pos
