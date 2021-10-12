class_name Hitbox
extends Area

signal failed
signal hit(damage)

var health = 100

func _ready() -> void:
	connect("body_entered", self, "_on_collided")
	
func _on_collided(body: Node):
	var bullet = body as Bullet
	
	if bullet:
		health -= bullet.damage
		
		emit_signal("hit", bullet.damage)
		
		if health <= 0.0:
			emit_signal("failed")
			monitoring = false
			monitorable = false
		
		bullet.queue_free()
