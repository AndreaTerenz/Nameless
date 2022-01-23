class_name Hitbox
extends Area

signal killed
signal hit(damage)
signal changed(amnt)
signal healed(amnt)

var initial_health : float = 100
var health : float = 100 

func _ready() -> void:
	connect("body_entered", self, "_on_collided")
	connect("area_entered", self, "_on_area_collided")
	
func set_initial_hp(h):
	initial_health = h
	set_health(h, true)
	
func decrease_hp(delta = health):
	set_health(health - delta)
	
func increase_hp(delta = health):
	set_health(health - delta)
	
func set_health(val, quiet := false):
	var tmp = health
	health = max(0.0, val)
		
	if health == 0.0:
		if not quiet:
			emit_signal("killed")
		monitoring = false
		monitorable = false
	elif not quiet:
		emit_change(health - tmp)
			
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
	elif body is Area:
		set_health(0)
		
func _on_area_collided(area: Area):
	if area is KillZone:
		set_health(0)
	
