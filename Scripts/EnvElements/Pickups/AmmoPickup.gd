class_name AmmoPickup
extends BasePickup

export(PackedScene) var bullet_scn = preload("res://Scenes/Weapons/Bullet.tscn")

func _on_interact(sender: Node = null):
	if not permanent:
		queue_free()
		
	return Inventory.InventoryEntry.new(
		item_name,
		Inventory.InventoryEntry.ENTRY_T.AMMO,
		amount,
		1,
		false,
		bullet_scn
	)
