class_name HealthPickup
extends BasePickup

@export var amount = 20.0; # (float, 0.1, 100.0, 0.1)

func _on_interact(sender: Node = null):
	var hb : Hitbox = Globals.player.hitbox
	
	if hb.would_change(amount):
		hb.increase_hp(amount)
		remove_at()
