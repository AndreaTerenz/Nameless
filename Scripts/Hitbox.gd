class_name Hitbox
extends Area

signal killed
signal hit(damage)

var health : float = 100 setget set_health

func _ready() -> void:
	connect("body_entered", self, "_on_collided")
	connect("area_entered", self, "_on_area_collided")
	
func set_health(val):
	var tmp = health
	health = max(0.0, val)
		
	if health == 0.0:
		emit_signal("killed")
		monitoring = false
		monitorable = false
	else:
		emit_signal("hit", abs(tmp - health))
	
func _on_collided(body: Node):
	if body is Bullet:
		var bullet = body as Bullet
		set_health(health - bullet.damage)
		bullet.queue_free()
	elif body is Area:
		set_health(0)
		
func _on_area_collided(area: Area):
	if area is KillZone:
		set_health(0)
	
