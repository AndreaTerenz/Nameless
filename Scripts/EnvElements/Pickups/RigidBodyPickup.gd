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
	collision_layer = 0
	collision_mask = 0
	Utils.set_layer_bit_in_object(self, "RBPickups")
	Utils.set_mask_bits_in_object(self, ["RBPickups", "Env", "Player"])

func picked_up(by: Node, distance := 1.0):
	emit_signal("picked_up", by)
	
	mode = RigidBody.MODE_KINEMATIC
	#Console.write_line("RBPickup " + name + " switched to MODE_KINEMATIC")
	holder = by
	
	Utils.transfer_node(self, holder)
	Utils.toggle_mask_bit_in_object(self, "Player")
	
	transform.origin *= 0.0
	rotation *= 0.0
	
	if distance > 0.0:
		translate(Vector3.FORWARD * distance)
	
func dropped():
	emit_signal("dropped", holder)
	#Console.write_line("Dropped RBPickup " + name)
	_release()

func launched(strength, forward_origin: Spatial = null):
	emit_signal("launched", holder, strength) 
	if not forward_origin:
		forward_origin = holder
		
	_release()
	apply_central_impulse(-Utils.get_dir_vector(forward_origin, Vector3.AXIS_Z) * strength)

func _release():
	mode = RigidBody.MODE_RIGID
	sleeping = false
	#Console.write_line("RBPickup " + name + " switched to MODE_RIGID")
	holder = null
	
	var old_pos = Utils.get_global_pos(self)
	Utils.transfer_node(self, initial_parent)
	Utils.toggle_mask_bit_in_object(self, "Player")
	self.transform.origin = old_pos
