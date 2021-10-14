class_name BaseWeapon
extends Spatial

signal attacked

export var aimable := true

var target_group := "Enemies"
var enabled = false

func _input(event: InputEvent) -> void:
	if _check_fire():
		attack()
		
func _check_fire():
	return Input.is_action_just_released("fire")

func attack():
	if enabled:
		_on_attack()
		#it may change after the attack
		if enabled:
			emit_signal("attacked")
	
func _on_attack():
	pass
