class_name Bullet
extends RigidBody

export(float, 150.0, 1000.0, 10.0) var speed = 150.0
export(float, 10.0, 150.0, 0.5) var max_dist = 10.0
export(float) var damage = 10.0

var start : Vector3
var target_group := "Enemies"

func _ready():
	contact_monitor = true
	contacts_reported = 512
	mass = 1
	gravity_scale = 0
	
	connect("body_entered", self, "_on_collision")

func setup(tr: Transform):
	transform = tr
	start = global_transform.origin
	apply_impulse(Vector3.ZERO, transform.basis.x * speed)

func _physics_process(delta: float) -> void:
	if translation.distance_to(start) >= max_dist:
		queue_free()

func _on_collision(body: Node):
	queue_free()
