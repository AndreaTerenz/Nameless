class_name Bullet
extends RigidBody

export(PackedScene) var hitmark_scn = preload("res://Scenes/Weapons/BulletHole.tscn")

export(float, 150.0, 1000.0, 10.0) var speed = 150.0
export(float, 10.0, 150.0, 0.5) var max_dist = 10.0
export(float) var damage = 10.0

var start : Vector3
var coll_point = null
var coll_normal = null
var target_group := "Enemies"

var phys_state : PhysicsDirectBodyState = null

onready var coll_shape = $CollisionShape

func _ready():
	set_as_toplevel(true)
	contact_monitor = true
	contacts_reported = 512
	mass = 1
	gravity_scale = 0
	
	connect("body_entered", self, "_on_collision")

	start = global_transform.origin
	
	if Globals.player:
		var aim_ray : RayCast = Globals.player.aim_ray
		
		if aim_ray.is_colliding():
			coll_point = aim_ray.get_collision_point()
			coll_normal = aim_ray.get_collision_normal()
			look_at(coll_point, Vector3.UP)
	
	apply_impulse(Vector3.ZERO, -transform.basis.z * speed)

func _physics_process(delta: float) -> void:
	if translation.distance_to(start) >= max_dist:
		queue_free()

func _integrate_forces(state: PhysicsDirectBodyState) -> void:
	if not coll_point:
		if state.get_contact_count() > 0:
			phys_state = state
		else:
			phys_state = null

func _on_collision(body: Node):
	print(body.name)
	var hitmark : MeshInstance = hitmark_scn.instance()
	body.add_child(hitmark)
	
	var p := Vector3.ZERO
	var n := Vector3.ZERO
	
	if coll_point:
		p = coll_point
		n = coll_normal
	else:
		p = coll_shape.global_transform.origin
		n = phys_state.get_contact_local_normal(0)
		
	hitmark.setup(p, n)
	
	queue_free()
