extends Node

static func vec3_horizontal(v: Vector3):
	return Vector2(v.x, v.z)
	
static func round_vec2(v : Vector2, digits : int = 3):
	return Vector2(stepify(v.x, pow(10, -digits)), stepify(v.y, pow(10, -digits)))
	
static func delete_children(node):
	for n in node.get_children():
		n.queue_free()

static func log_line(obj: Node, msg: String):
	var time = OS.get_time()
	var time_str = "%s:%s:%s" % [str(time.hour), str(time.minute), str(time.second)]
	Console.write_line("@%s [%s]: %s" % [time_str, obj.name, msg])
