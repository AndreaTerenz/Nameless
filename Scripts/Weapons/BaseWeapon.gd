class_name BaseWeapon
extends Spatial

signal attacked

export var aimable := true

var player_inventory : Inventory = null
var target_group := "Enemies"
var enabled = false setget set_enabled

func set_enabled(value):
	if value != enabled:
		enabled = value
	
		if enabled:
			_on_enabled()
		else:
			_on_disabled()
			
		_on_enabled_changed()
	
func _physics_process(delta: float) -> void:
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
	
func _on_enabled_changed():
	pass
	
func _on_enabled():
	pass
	
func _on_disabled():
	pass
	
func _on_new_entry(entry: Inventory.InventoryEntry) -> void:
	pass

func _on_updated_entry(entry: Inventory.InventoryEntry) -> void:
	pass
