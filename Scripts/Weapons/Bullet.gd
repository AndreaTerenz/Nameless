class_name Bullet
extends RigidBody3D

@export var hitmark_scn: PackedScene = preload("res://Scenes/Weapons/BulletHole.tscn")

@export var speed = 150.0 # (float, 150.0, 1000.0, 10.0)
@export var max_dist = 10.0 # (float, 10.0, 150.0, 0.5)
@export var damage: float = 10.0

var start : Vector3
var coll_point = null
var coll_normal = null
var target_group := "Enemies"

var phys_state : PhysicsDirectBodyState3D = null

@onready var coll_shape = $CollisionShape3D

func _ready():
	set_as_top_level(true)
	contact_monitor = true
	max_contacts_reported = 512
	mass = 1
	gravity_scale = 0
	
	connect("body_entered",Callable(self,"_on_collision"))

	start = global_transform.origin
	
	if Globals.player:
		var aim_ray : RayCast3D = Globals.player.aim_ray
		
		if aim_ray.is_colliding():
			coll_point = aim_ray.get_collision_point()
			coll_normal = aim_ray.get_collision_normal()
			look_at(coll_point, Vector3.UP)
	
	apply_impulse(-transform.basis.z * speed, Vector3.ZERO)

func _physics_process(_delta: float) -> void:
	if is_too_far():
		delete()
		
func is_too_far() -> bool:
	return position.distance_to(start) >= max_dist

func _on_delete():
	pass
	
func delete():
	_on_delete()
	queue_free()

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not coll_point:
		if state.get_contact_count() > 0:
			phys_state = state
		else:
			phys_state = null

func _on_collision(body: Node):
	var hitmark : MeshInstance3D = hitmark_scn.instantiate()
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
