class_name Prop
extends RigidBody

func _ready() -> void:
	add_to_group("props")

func push(from: Vector3, force: float):
	var dir = from.direction_to(Utils.get_global_pos(self))
	add_central_force(dir * force)
