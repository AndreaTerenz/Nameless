class_name BaseGun
extends BaseWeapon

signal shot

@export var muzze_path: NodePath = "$Muzzle"
@export var crosshair_text: Texture2D = preload("res://Assets/Sprites/crosshair.svg")

@onready var muzzle = get_node(muzze_path)

func shoot():
	_on_shoot()
	if enabled:
		emit_signal("shot")
	
func _on_attack():
	shoot()
	
func _on_shoot():
	pass
