class_name InventoryPickup
extends BasePickup

@export var item_name: String = "Std Bullet"
@export var amount = 20 # (int, 1, 100)
@export var weight_each = 0.0 # (float, 0.0, 100.0, .1)

func _ready() -> void:
	super._ready()
	interact_txt = "Pick up %s" % [item_name]

func _on_interact(sender: Node = null):
	if inventory_has_space():
		remove_at()
			
		return _get_entry()
		
	return null
	
func _get_entry() -> Inventory.InventoryEntry:
	return null

func inventory_has_space():
	var e : Inventory.InventoryEntry = _get_entry()
	return (e == null) or Globals.inventory.could_carry(e.total_weight)
