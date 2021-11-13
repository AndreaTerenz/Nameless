class_name AmmoPickup
extends Interactable

export(PackedScene) var bullet_scn = preload("res://Scenes/Weapons/Bullet.tscn")
export(int, 1, 100) var amount = 2
export(bool) var permanent = false

func _on_interact(sender: Node = null):
	if not permanent:
		queue_free()
	return {
		"type": "ammo",
		"bullet": bullet_scn,
		"amount": amount
	}
