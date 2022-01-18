extends Node

enum TERNARY {
	TRUE,
	FALSE,
	NONE
}

static func bool_to_sign(b: bool):
	return 1 if b else -1

static func vec3_horizontal(v: Vector3):
	return Vector2(v.x, v.z)
	
static func round_vec2(v : Vector2, digits : int = 3):
	return Vector2(stepify(v.x, pow(10, -digits)), stepify(v.y, pow(10, -digits)))
	
static func delete_children(node):
	for n in node.get_children():
		n.queue_free()

static func log_line(obj: Node, msg: String):
	var time = OS.get_time()
	var time_str = "%02d:%02d:%02d" % [time.hour, time.minute, time.second]
	Console.write_line("@%s [%s]: %s" % [time_str, obj.name, msg])
