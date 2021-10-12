extends Camera

var std_fov = 65.0
var sprint_fov = 85.0
var zoom_fov = 50.0

var fov_change_rate = .1
var zoomed: bool = false
var sprinting: bool = false
var target_fov: float = std_fov

func set_sprinting_fov(sprnt: bool):
	sprinting = sprnt
		
func _process(delta: float) -> void:
	target_fov = std_fov
	
	if zoomed:
		target_fov = zoom_fov
	elif sprinting:
		target_fov = sprint_fov
	
	fov = lerp(fov, target_fov, fov_change_rate)
