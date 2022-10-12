class_name BaseWeapon
extends Node3D

signal attacked

@export var icon: CompressedTexture2D := preload("res://Assets/Sprites/UI/item_slots/empty_slot.png")
@export var aimable: bool := true
@export var entry_name: String = ""

var target_group := "Enemies"
var enabled = false :
	get:
		return enabled # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_enabled

var player_inventory : Inventory :
	get:
		return player_inventory # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_inv
func set_inv(inv: Inventory):
	player_inventory = inv
	
	inv.connect("new_entry",Callable(self,"_on_new_entry"))
	inv.connect("updated_entry",Callable(self,"_on_updated_entry"))
	inv.add_entry_listener(entry_name, self)
	
func _get_entry_name():
	return ""
	
func _get_entry() -> Inventory.InventoryEntry:
	return player_inventory.first_entry_by_name(entry_name)

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

func update_ui():
	if is_inside_tree():
		_ui()
		
func _ui():
	pass
	
func _ui_init():
	pass

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
