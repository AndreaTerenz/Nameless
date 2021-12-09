class_name AmmoPickup
extends BasePickup

export(PackedScene) var bullet_scn = preload("res://Scenes/Weapons/Bullet.tscn")

func _on_interact(sender: Node = null):
	if not permanent:
		queue_free()
	return {
		"name": "Std Bullet",
		"type": Inventory.InventoryEntry.ENTRY_T.AMMO,
		"quantity": amount,
		"weight": 1,
		"unique": false
	}
