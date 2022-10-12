class_name Hitbox
extends Area3D

signal killed
signal no_change
signal hit(damage)
signal changed(amnt)
signal healed(amnt)

var last_change_from := Vector3.ZERO
var max_health : float = 100
var start_health : float = 100
@export var health : float = 100 

func _ready() -> void:
	connect("body_entered",Callable(self,"_on_collided"))
	connect("area_entered",Callable(self,"_on_area_collided"))
	
func set_initial_hp(h):
	set_health(h, Vector3.ZERO, true)
	
func would_change(delta: float):
	var v := health + delta
	
	return health != clamp(v, 0, max_health)
	
func decrease_hp(delta = health, from := Vector3.ZERO):
	set_health(health - delta, from)
	
func increase_hp(delta, from := Vector3.ZERO):
	set_health(health + delta, from)
	
func set_health(val, from := Vector3.ZERO, quiet := false):
	last_change_from = from
	val = clamp(val, 0, max_health)
	
	if val != health:
		var orig_hp = health
		health = max(0.0, val)
			
		if health == 0.0:
			if not quiet:
				emit_signal("killed")
			monitoring = false
			monitorable = false
		elif not quiet:
			emit_change(health - orig_hp)
	else:
		emit_signal("no_change")
			
func emit_change(amount):
	emit_signal("changed", amount)
	
	if amount < 0:
		emit_signal("hit", abs(amount))
	elif amount > 0:
		emit_signal("healed", abs(amount))
	
func _on_collided(body: Node):
	if body is Bullet:
		var bullet = body as Bullet
		decrease_hp(bullet.damage)
		bullet.queue_free()
	elif body is Area3D:
		set_health(0)
		
func _on_area_collided(area: Area3D):
	if area is KillZone:
		set_health(0)
	
