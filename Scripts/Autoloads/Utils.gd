extends Node

var layers = []

func _ready() -> void:
	for i in range(1, 21):
		layers.append(ProjectSettings.get_setting("layer_names/3d_physics/layer_%d" % i))

func get_layer_bit(name: String):
	return layers.find(name)
	
func get_layer_bit_in_object(obj: CollisionObject3D, name: String) -> bool:
	return obj.get_collision_layer_value(get_layer_bit(name))
	
func get_mask_bit_in_object(obj: Node3D, name: String) -> bool:
	if obj is CollisionObject3D or obj is RayCast3D:
		return obj.get_collision_mask_value(get_layer_bit(name))
	return false
	
func set_layer_bit_in_object(obj: CollisionObject3D, name: String, value := true):
	var bit = get_layer_bit(name)
	obj.set_collision_layer_value(bit, value)
	
func set_mask_bit_in_object(obj: Node3D, name: String, value := true):
	if obj is CollisionObject3D or obj is RayCast3D:
		var bit = get_layer_bit(name)
		obj.set_collision_mask_value(bit, value)
	
func set_layer_bits_in_object(obj: CollisionObject3D, names: PackedStringArray, value := true):
	for n in names:
		set_layer_bit_in_object(obj, n, value)
		
func set_mask_bits_in_object(obj: Node3D, names: PackedStringArray, value := true):
	if obj is CollisionObject3D or obj is RayCast3D:
		for n in names:
			set_mask_bit_in_object(obj, n, value)
	
func toggle_layer_bit_in_object(obj: CollisionObject3D, name: String):
	var current = get_layer_bit_in_object(obj, name)
	set_layer_bit_in_object(obj, name, not current)
	
func toggle_mask_bit_in_object(obj: Node3D, name: String):
	if obj is CollisionObject3D or obj is RayCast3D:
		var current = get_mask_bit_in_object(obj, name)
		set_mask_bit_in_object(obj, name, not current)
	
func toggle_layer_bits_in_object(obj: CollisionObject3D, names: PackedStringArray):
	for n in names:
		toggle_layer_bit_in_object(obj, n)
		
func toggle_mask_bits_in_object(obj: Node3D, names: PackedStringArray):
	if obj is CollisionObject3D or obj is RayCast3D:
		for n in names:
			toggle_mask_bit_in_object(obj, n)
			
func toggle_area(a: Area3D, stat: bool):
	a.set_deferred("monitorable", stat)
	a.set_deferred("monitoring", stat)

func bool_to_sign(b: bool):
	return 1 if b else -1

func vec3_horizontal(v: Vector3) -> Vector2:
	return vec3_remove_axis(v, Vector3.AXIS_Y)
	
func vec3_remove_axis(v: Vector3, axis : int = Vector3.AXIS_Y) -> Vector2:
	match axis:
		Vector3.AXIS_X: return Vector2(v.y, v.z)
		Vector3.AXIS_Y: return Vector2(v.x, v.z)
		Vector3.AXIS_Z: return Vector2(v.x, v.y)
		
	return Vector2.ZERO
	
func vec3_deg2rad(v: Vector3):
	return Vector3(deg_to_rad(v.x), deg_to_rad(v.y), deg_to_rad(v.z))
	
func vec2_deg2rad(v: Vector2):
	return Vector2(deg_to_rad(v.x), deg_to_rad(v.y))
	
func vec3_rad2deg(v: Vector3):
	return Vector3(rad_to_deg(v.x), rad_to_deg(v.y), rad_to_deg(v.z))
	
func vec2_rad2deg(v: Vector2):
	return Vector2(rad_to_deg(v.x), rad_to_deg(v.y))
	
func mirror_vec2(origin: Node2D, to_mirror: Vector2):
	var tm_local = origin.to_local(to_mirror)
	return origin.to_global(-tm_local)
	
func mirror_vec3(origin: Node3D, to_mirror: Vector3):
	var tm_local = origin.to_local(to_mirror)
	return origin.to_global(-tm_local)
	
func round_vec2(v : Vector2, digits : int = 3):
	return Vector2(snapped(v.x, pow(10, -digits)), snapped(v.y, pow(10, -digits)))
	
func round_vec3(v : Vector3, digits : int = 3):
	return Vector3( \
		snapped(v.x, pow(10, -digits)), \
		snapped(v.y, pow(10, -digits)), \
		snapped(v.z, pow(10, -digits)))

func root_origin() -> Vector3:
	var root = get_tree().current_scene
	
	if root is Node3D:
		return root.global_transform.origin
	
	return Vector3.ZERO
	
func get_global_rotation(obj: Node3D):
	return obj.global_transform.basis
	
func get_global_pos(obj: Node3D, relative_to_root := true) -> Vector3:
	return obj.global_transform.origin - (root_origin() * float(relative_to_root))
	
func set_global_pos(obj: Node3D, origin: Vector3, relative_to_root := true):
	obj.global_transform.origin = origin + (root_origin() * float(relative_to_root))
	
func copy_global_pos(source: Node3D, dest: Node3D):
	dest.global_transform.origin = source.global_transform.origin
	
func get_dir_vector(obj: Node3D, axis := Vector3.AXIS_Z) -> Vector3:
	match axis:
		Vector3.AXIS_X: return obj.global_transform.basis.x
		Vector3.AXIS_Y: return obj.global_transform.basis.y
		Vector3.AXIS_Z: return obj.global_transform.basis.z
		
	return Vector3.ZERO
	
func local_direction(obj: Node3D, direction : Vector3) -> Vector3:
	match direction:
		Vector3.BACK: return -obj.global_transform.basis.z
		Vector3.FORWARD: return obj.global_transform.basis.z
			
		Vector3.UP: return obj.global_transform.basis.y
		Vector3.DOWN: return -obj.global_transform.basis.y
		
		Vector3.RIGHT: return -obj.global_transform.basis.x
		Vector3.LEFT: return obj.global_transform.basis.x
		
	return Vector3.ZERO

func lerp_rot_towards(obj: Node3D, target: Node3D, amount: float = 1.0) -> Quaternion:
	var target_pos = get_global_pos(target)
	var obj_global_tr = obj.global_transform
	
	var wtransform = obj_global_tr.looking_at(target_pos,Vector3.UP)
	
	return transform2quat(obj_global_tr).slerp(transform2quat(wtransform), amount)
	
func transform2quat(tr: Transform3D) -> Quaternion:
	return Quaternion(tr.basis)
	
func rotate_with_mouse(event: InputEventMouseMotion, node: Node3D, x_rot_node : Node3D, sensitivity := .1 , hrl_up := 80.0, hrl_down := -1, invert_y := false):
	var event_rel : Vector2 = vec2_deg2rad(-event.relative * sensitivity)
	var y_rot = event_rel.x

	node.rotate_y(y_rot)
	x_rot_node.rotate_x(event_rel.y * -bool_to_sign(invert_y))

	if hrl_down < 0:
		hrl_down = hrl_up
	x_rot_node.rotation.x = clamp(x_rot_node.rotation.x, -deg_to_rad(hrl_down), deg_to_rad(hrl_up))
	
func delete_children(node):
	for n in node.get_children():
		n.queue_free()
		
func transfer_node(obj: Node, new_parent: Node = null):
	if obj != new_parent:
		obj.get_parent().remove_child(obj)
		
		if new_parent:
			new_parent.add_child(obj)
		else:
			get_tree().root.add_child(obj)

func log_line(obj: Node, msg: String):
	var time = Time.get_time_string_from_system()
	Console.write_line("@%s [%s]: %s" % [time, obj.name, msg])

func list_files_in_directory(path, extensions = [], include_hidden = false) -> PackedStringArray:
	var files : PackedStringArray = []
	var dir = DirAccess.open(path)

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
	
func spatial_to_local(s: Node3D, orig: Node3D) -> Vector3:
	return orig.to_local(get_global_pos(s))
	
func vec2_to_list(v: Vector2) -> Array:
	return [v.x, v.y]
	
func vec3_to_list(v: Vector3) -> Array:
	return [v.x, v.y, v.z]
	
func vec2_abs(v: Vector2) -> Vector2:
	return Vector2(abs(v.x), abs(v.y))
	
func vec3_abs(v: Vector3) -> Vector3:
	return Vector3(abs(v.x), abs(v.y), abs(v.z))

func float_to_vec2(v: float) -> Vector2:
	return Vector2.ONE * v

func float_to_vec3(v: float) -> Vector3:
	return Vector3.ONE * v
	
func aabb_has_point(cube: AABB, p: Vector3) -> bool:
	p = vec3_abs(p)
	var half_size : Vector3 = vec3_abs(cube.size / 2)
	
	return (p.x <= half_size.x and \
			p.y <= half_size.y and \
			p.z <= half_size.z)

func aabb_has_sphere(cube: AABB, p: Vector3, r: float) -> bool:
	var second_cube = cube.grow(-r)
	
	return aabb_has_point(second_cube, p)
	
func aabb_from_center(c: Vector3, size: Vector3) -> AABB:
	return AABB(c - size, size)

func aabb_at_origin(size: Vector3) -> AABB:
	return aabb_from_center(Vector3.ZERO, size)
	
func engine_description() -> String:
	var eng_info = Engine.get_version_info()
	
	return "Godot %s.%s.%s (%s)" % \
		[eng_info.major, eng_info.minor, eng_info.patch, eng_info.status]

func try_get_node(node_name: String, from: Node, default = null):
	if from.find_child(node_name):
		return from.get_node(node_name)
		
	return default

func control_center_pivot(ctrl: Control):
	control_set_relative_pivot(ctrl, Vector2.ONE * 0.5)

func control_set_relative_pivot(ctrl: Control, pivot_rel: Vector2):
	ctrl.pivot_offset = ctrl.size * pivot_rel

func is_debug():
	return OS.has_feature("debug")
	
func is_editor():
	return OS.has_feature("editor")
	
func is_release():
	return OS.has_feature("release")
