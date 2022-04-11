extends TriggerZone
class_name LooKTrigger


func get_targets() -> Array:
	# Enables detecting other objects
	var objects := [Globals.player]
	
	if Globals.player:
		objects += [Globals.player.look_ray]
		
	return objects
