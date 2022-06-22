class_name AmmoPickup
extends InventoryPickup

export(PackedScene) var bullet_scn = preload("res://Scenes/Weapons/Bullet.tscn")

func _get_entry():
	return Inventory.InventoryEntry.new(
		item_name,
		Inventory.InventoryEntry.ENTRY_T.AMMO,
		amount,
		weight_each,
		false,
		bullet_scn
	)
