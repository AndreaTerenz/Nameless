extends Spatial

var enabled: bool = true setget set_enabled
var flipped: bool = false

onready var check_top = $"StairsCheck Top"
onready var check_mid = $StairsCheck
onready var check_bottom = $"StairsCheck Bottom"

func set_enabled(value):
	enabled = value
	check_top.enabled = enabled
	check_mid.enabled = enabled
	check_bottom.enabled = enabled
	if not(enabled):
		flipped = false

func any_collisions() -> bool:
	return check_top.is_colliding() or check_mid.is_colliding() or check_bottom.is_colliding()
	
func top_collision() -> bool:
	return check_top.is_colliding() if not(flipped) else check_bottom.is_colliding()
	
func bottom_collision() -> bool:
	return check_bottom.is_colliding() if not(flipped) else check_top.is_colliding()
