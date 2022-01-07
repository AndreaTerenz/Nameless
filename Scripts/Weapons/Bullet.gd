class_name Bullet
extends RigidBody

export(PackedScene) var hitmark_scn = preload("res://Scenes/Weapons/BulletHole.tscn")

export(float, 150.0, 1000.0, 10.0) var speed = 150.0
export(float, 10.0, 150.0, 0.5) var max_dist = 10.0
export(float) var damage = 10.0

var start : Vector3
var target_group := "Enemies"

var phys_state : PhysicsDirectBodyState = null

onready var coll_shape = $CollisionShape

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

func _integrate_forces(state: PhysicsDirectBodyState) -> void:
	if state.get_contact_count() > 0:
		phys_state = state
	else:
		phys_state = null

func _on_collision(body: Node):
	var hitmark : MeshInstance = hitmark_scn.instance()
	body.add_child(hitmark)
	
	var pos = coll_shape.global_transform.origin
	hitmark.global_transform.origin = pos
	
	if phys_state:
		var normal = phys_state.get_contact_local_normal(0)
		hitmark.look_at(pos + normal, Vector3.UP)
		hitmark.rotate_y(PI)
		
	queue_free()
