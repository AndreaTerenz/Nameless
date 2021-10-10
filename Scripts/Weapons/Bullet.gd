class_name Bullet
extends RigidBody

var start : Vector3

func setup(tr: Transform):
	transform = tr
	start = transform.origin
	apply_impulse(Vector3.ZERO, transform.basis.x * 150.0)

func _physics_process(delta: float) -> void:
	if translation.distance_to(start) > 10.0:
		queue_free()

