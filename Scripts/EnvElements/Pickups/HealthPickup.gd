class_name HealthPickup
extends BasePickup

export(float, 0.1, 100.0, 0.1) var amount = 20.0;

func _on_interact(sender: Node = null):
	var hb : Hitbox = Globals.player.hitbox
	
	if hb.would_change(amount):
		hb.increase_hp(amount)
		remove()
