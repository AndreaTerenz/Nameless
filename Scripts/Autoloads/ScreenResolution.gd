extends Node

enum {
	RATIO_4_3,
	RATIO_16_9,
	RATIO_21_9
}

var ratios := {
	RATIO_4_3: 4/3,
	RATIO_16_9: 16/9,
	RATIO_21_9: 21/9,
}

var size := Vector2.ZERO
var type := -1

func _init(w: int = 0, h: int = 0):
	_load(w, h)
	
			
func _load(w: int = 0, h: int = 0):
	var native := OS.get_screen_size()
	
	if (w <= 0 or h <= 0):
		w = native.x
		h = native.y
		
	size = Vector2(w,h)
	
	var ratio = get_ratio()
	
	for r in ratios.keys():
		if type == -1 or (abs(ratio - ratios[r]) < abs(ratio - ratios[type])):
			type = r

func is_native():
	var native := OS.get_screen_size()
	return size.x == native.x and size.y == native.y

func get_pixel_count():
	return int(size.x) * int(size.y)
	
func get_ratio():
	return size.x / size.y

func _to_string() -> String:
	return "%d x %d" % [int(size.x), int(size.y)]
