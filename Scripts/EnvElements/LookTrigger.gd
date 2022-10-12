extends TriggerZone
class_name LooKTrigger

@export var include_player: bool = true

func get_targets() -> Array:
	# Enables detecting other objects
	var objects := []
	
	if include_player:
		objects += [Globals.player]
	
	if Globals.player:
		objects += [Globals.player.look_ray]
		
	return objects
