class_name BasePickup
extends Interactable

export(String) var item_name = "Std Bullet"
export(int, 1, 100) var amount = 20
export(float, 0.0, 100.0, .1) var weight_each = 0.0
export(bool) var permanent = false

func _ready() -> void:
	continuous = false

func _on_interact(sender: Node = null):
	if inventory_has_space():
		if not permanent:
			queue_free()
			
		return _get_entry()
		
	return null
	
func _get_entry() -> Inventory.InventoryEntry:
	return null

func inventory_has_space():
	var e : Inventory.InventoryEntry = _get_entry()
	return (e == null) or Globals.inventory.could_carry(e.total_weight)
