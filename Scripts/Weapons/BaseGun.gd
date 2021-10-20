class_name BaseGun
extends BaseWeapon

signal shot

export(NodePath) var muzze_path = "$Muzzle"
export(Texture) var crosshair_text = preload("res://.import/crosshair.svg-deb0bcc8d1290c31088c8dfda3f32476.stex")

onready var muzzle = get_node(muzze_path)

func shoot():
	_on_shoot()
	if enabled:
		emit_signal("shot")
	
func _on_attack():
	shoot()
	
func _on_shoot():
	pass
