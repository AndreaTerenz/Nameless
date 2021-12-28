class_name BasePickup
extends Interactable

export(String) var item_name = "Std Bullet"
export(int, 1, 100) var amount = 20
export(bool) var permanent = false

func _ready() -> void:
	continuous = false

func _on_interact(sender: Node = null):
	if not permanent:
		queue_free()
		
	return _get_entry()
	
func _get_entry():
	return null
