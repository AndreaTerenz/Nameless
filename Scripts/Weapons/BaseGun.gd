class_name BaseGun
extends BaseWeapon

signal shot

export(NodePath) var muzze_path

onready var muzzle = get_node(muzze_path)

func shoot():
	emit_signal("shot")
	_on_shoot()
	
func _on_attack():
	shoot()
	
func _on_shoot():
	pass
