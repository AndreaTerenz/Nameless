extends Node

static func bool_to_sign(b: bool):
	return 1 if b else -1
	
static func map(v: float, i_start: float, i_end: float, f_start: float, f_end: float, clamped := false) -> float:
	var output := range_lerp(v, i_start, i_end, f_start, f_end)
	
	return clamp(output, f_start, f_end) if clamped else output

static func vec3_horizontal(v: Vector3) -> Vector2:
	return vec3_remove_axis(v, Vector3.AXIS_Y)
	
static func vec3_remove_axis(v: Vector3, axis : int = Vector3.AXIS_Y) -> Vector2:
	match axis:
		Vector3.AXIS_X: return Vector2(v.y, v.z)
		Vector3.AXIS_Y: return Vector2(v.x, v.z)
		Vector3.AXIS_Z: return Vector2(v.x, v.y)
		
	return Vector2.ZERO
	
static func vec3_deg2rad(v: Vector3):
	return Vector3(deg2rad(v.x), deg2rad(v.y), deg2rad(v.z))
	
static func vec2_deg2rad(v: Vector2):
	return Vector2(deg2rad(v.x), deg2rad(v.y))
	
static func round_vec2(v : Vector2, digits : int = 3):
	return Vector2(stepify(v.x, pow(10, -digits)), stepify(v.y, pow(10, -digits)))
	
static func get_global_pos(obj: Spatial) -> Vector3:
	return obj.global_transform.origin
	
static func get_dir_vector(obj: Spatial, axis := Vector3.AXIS_Z) -> Vector3:
	match axis:
		Vector3.AXIS_X: return obj.transform.basis.x
		Vector3.AXIS_Y: return obj.transform.basis.y
		Vector3.AXIS_Z: return obj.transform.basis.z
		
	return Vector3.ZERO
	
static func rotate_with_mouse(event: InputEventMouseMotion, node: Spatial, x_rot_node : Spatial, sensitivity := .1 , head_rot_lim := 80.0, invert_y := false):
	var event_rel : Vector2 = Utils.vec2_deg2rad(-event.relative * sensitivity)
	var y_rot = event_rel.x

	node.rotate_y(y_rot)
	x_rot_node.rotate_x(event_rel.y * -bool_to_sign(invert_y))

	var hrl = deg2rad(head_rot_lim)
	x_rot_node.rotation.x = clamp(x_rot_node.rotation.x, -hrl, hrl)
	
static func delete_children(node):
	for n in node.get_children():
		n.queue_free()
		
static func transfer_node(obj: Node, new_parent: Node):
	obj.get_parent().remove_child(obj)
	new_parent.add_child(obj)

static func log_line(obj: Node, msg: String):
	var time = OS.get_time()
	var time_str = "%02d:%02d:%02d" % [time.hour, time.minute, time.second]
	Console.write_line("@%s [%s]: %s" % [time_str, obj.name, msg])

static func list_files_in_directory(path, extensions = [], include_hidden = false) -> PoolStringArray:
	var files : PoolStringArray = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	var done = false
	while not done:
		var file : String = dir.get_next()
		done = (file == "")
		
		var is_visible = (not file.begins_with(".") or include_hidden)
		var correct_ext = (len(extensions) == 0 or file.get_extension() in extensions)
		
		if is_visible and correct_ext:
			files.append(file)

	dir.list_dir_end()

	return files
