extends Node

signal paused
signal unpaused
signal pause_changed(state)
signal player_set(p)
signal scene_manager_set(sm)
signal screenshot(path)

enum GROUPS  {
	ENEMIES,
	PLAYER,
	FRIENDLY,
	NEUTRAL,
	SUPPLIES
}

enum PLAYER_STATE {
	GAME,
	CINEMATIC,
	NOCLIP
}

enum INPUT_TYPE {
	KEYBOARD,
	MOUSE,
	#MF here preparing for console support lol
	JOYCON,
	PS_CONTR,
	XB_CONTR
}

enum UI_BTN_THEMES {
	DARK,
	LIGHT
}

const THEMES_SUFFIX : Dictionary = {
	UI_BTN_THEMES.DARK : "Dark",
	UI_BTN_THEMES.LIGHT : "Light",
}

const KILL_ZN_GRP = "KillZones"
const TRGGR_ZN_GRP = "Triggers"
const WALL_GRP = "Walls"
const PROP_GRP = "Props"
const EXPL_PROP_GRP = "Expl_Props"

const UI_BTN_THEME := UI_BTN_THEMES.DARK
const UI_BTN_BASE_DIR := "res://Assets/UI Buttons"

const PAUSE_TOGGLE := 0
const UNPAUSED := -1
const PAUSED := 1

var layers : Array = []
var group_layers : Dictionary = {
	GROUPS.ENEMIES: "Enemies",
	GROUPS.FRIENDLY: "Friendlies",
	GROUPS.NEUTRAL: "NPCs",
}

var scene_to_load := ""
var in_game := true

var player : Player = null
var scene_mngr : SceneManager = null
var player_set := false
var scn_mngr_set := false

var inventory : Inventory = null
var current_ui : GameUI = null

func _ready() -> void:
	var args = OS.get_cmdline_args()
	Console.write_line("Running with arguments: '%s'" % [" ".join(args)])
	
	if Input.get_connected_joypads().size() > 0:
		Console.Log.error("CONTROLLER INPUT NOT SUPPORTED AT THIS TIME")
	
	for i in range(1, 21):
		layers.append(ProjectSettings.get_setting("layer_names/3d_physics/layer_%d" % i))
	
	Console.connect("toggled", self, "_on_console_toggled")
	
	Console.add_command("toggle_triggers", self, "toggle_triggers")\
	.set_description("toggles triggers visibility")\
	.register()
	
	Console.add_command("toggle_killzones", self, "toggle_killzones")\
	.set_description("toggles killzones visibility")\
	.register()
	
	Console.add_command("toggle_walls", self, "toggle_walls")\
	.set_description("toggles walls visibility")\
	.register()
	
	Console.add_command("debug_draw", self, "debug_draw")\
	.set_description("sets debug draw mode (0 to disable)")\
	.add_argument("mode", TYPE_INT)\
	.register()
	
	Console.add_command("player_info", self, "get_player_info")\
	.set_description("show info about player")\
	.add_argument("mode", TYPE_STRING)\
	.register()
	
	Console.add_command("restart_scene", self, "restart_scene")\
	.set_description("reload current scene")\
	.register()
	
	Console.add_command("toggle_vsync", self, "toggle_vsync")\
	.set_description("toggle vsync")\
	.register()
	
	Console.add_command("get_vsync", self, "get_vsync")\
	.set_description("show vsync status")\
	.register()
	
	Console.add_command("set_windowed", self, "set_window_mode")\
	.set_description("Toggle fullscreen (0) or windowed (1)")\
	.add_argument("mode", TYPE_INT)\
	.register()
	
	Console.add_command("set_resolution", self, "set_resolution")\
	.set_description("[WIP] Set window resolution (0 0 to use the current screen's)")\
	.add_argument("width", TYPE_INT)\
	.add_argument("height", TYPE_INT)\
	.register()
	
#	Console.add_command("set_gravity", self, "set_gravity")\
#	.set_description("Set world gravity value (0 for default)")\
#	.add_argument("value", TYPE_REAL)\
#	.register()
	
#	Console.add_command("give_item", self, "give_item")\
#	.set_description("Add item to player inventory")\
#	.add_argument("name", TYPE_STRING)\
#	.add_argument("quantity", TYPE_INT)\
#	.register()

func _on_console_toggled(val: bool):
	if current_ui == null and in_game:
		set_paused(val)
	
func toggle_triggers():
	if not toggle_group(TRGGR_ZN_GRP):
		Console.Log.warn("No triggers in scene")
		
func toggle_killzones():
	if not toggle_group(KILL_ZN_GRP):
		Console.Log.warn("No killzones in scene")
		
func show_colliders(_t):
	# kinda broken
	# get_tree().debug_collisions_hint = bool(t)
	pass
		
func toggle_walls():
	if not toggle_group(WALL_GRP):
		Console.Log.warn("No invisible walls in scene")
	
func toggle_group(group: String, method := "toggle_shape") -> bool:
	var tree := get_tree()
	if len(tree.get_nodes_in_group(group)) == 0:
		return false
	
	tree.call_group(group, method)

	return true
	
func debug_draw(mode):
	if mode in range(0, 4):
		get_viewport().debug_draw = mode
		
func get_player_info(mode: String):
	if player:
		if mode == "full":
			mode = "transform+movement+surroundings+inventory"
			
		var infos = mode.split("+", false)
		for inf in infos:
			match inf:
				"transform":
					var origin = player.global_transform.origin
					var basis = player.global_transform.basis
					Console.write_line("Position: %s" % origin)
					Console.write_line("Basis X: %s" % basis.x)
					Console.write_line("Basis Y: %s" % basis.y)
					Console.write_line("Basis Z: %s" % basis.z)
					Console.write_line("On Floor: %s" % player.is_on_floor())
				"movement":
					Console.write_line("Mode: %s [%d]" % [player.mode_str(), player.mode])
					Console.write_line("On stairs: %s" % (player.mover is StairsMover))
					Console.write_line("Sprinting: %s" % (player.mover is StandardMover and player.mover.sprinting))
					Console.write_line("Crouching: %s" % (player.mover is StandardMover and player.mover.crouching))
				"surroundings":
					Console.write_line("Hostiles: %d" % (player.others_dict[GROUPS.ENEMIES]))
					Console.write_line("Friendlies: %d" % (player.others_dict[GROUPS.FRIENDLY]))
					Console.write_line("Neutrals: %d" % (player.others_dict[GROUPS.NEUTRAL]))
				"inventory":
					var inv : Inventory = player.inventory
					if len(inv.entries) > 0:
						for e in inv.entries:
							Console.write_line("%d %s [%d]" % [e.quantity, e.name, e.total_weight])
					else:
						Console.write_line("Inventory empty")
			Console.write_line()
	else:
		Console.Log.error("NO PLAYER IN SCENE")
		
func restart_scene():
	if Console.is_console_shown:
		Console.toggle_console()
	_restart()
		
func toggle_vsync():
	OS.vsync_enabled = not OS.vsync_enabled
	
func get_vsync():
	Console.write_line(OS.vsync_enabled)
	
func set_window_mode(mode: int):
	set_fullscreen(mode == 0)
	
func set_fullscreen(full: bool):
	OS.window_fullscreen = full
	#OS.window_resizable = not full
	
func set_resolution(w := 0, h := 0):
	var native := OS.get_screen_size()
	
	if (w == 0):
		w = native.x
	if (h == 0):
		h = native.y
		
	OS.window_size = Vector2(w, h)
	
func set_gravity(_value: float):
	"""
	well...maybe this'll be useful one day
	
	if value <= 0:
		value = 9.8
	PhysicsServer.area_set_param(get_viewport().find_world().get_space(),\\
	PhysicsServer.AREA_PARAM_GRAVITY, value)"""
	Console.write_line("This would actually be more complicated than it sounds and I don't feel like it bye")

########################################################

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("screenshot"):
		var image = get_viewport().get_texture().get_data()
		var usr_dir = OS.get_user_data_dir()
		var now = Time.get_datetime_string_from_system()
		var filename = "%s/screenshot_%s.png" % [usr_dir, now]
		
		image.flip_y()
		image.save_png(filename)
		Console.write_line("Screenshot saved @ '%s'" % filename)
		
		emit_signal("screenshot", filename)

func get_layer_bit(name: String):
	return layers.find(name)
	
func get_layer_bit_in_object(obj: CollisionObject, name: String):
	return obj.get_collision_layer_bit(get_layer_bit(name))
	
func get_mask_bit_in_object(obj: CollisionObject, name: String):
	return obj.get_collision_mask_bit(get_layer_bit(name))

func set_player(p):
	player = p
	player_set = (p != null)
	inventory = p.inventory if (p != null) else null
	
	if player_set:
		emit_signal("player_set", player)

func set_scene_manager(sm):
	scene_mngr = sm
	scn_mngr_set = (sm != null)
	
	if scn_mngr_set:
		emit_signal("scene_manager_set", scene_mngr)
	
func connect_to_player_set(obj: Node, method: String):
	if not player_set:
		connect("player_set", obj, method)
	else:
		obj.call(method, player)
	
func connect_to_scn_mngr_set(obj: Node, method: String):
	if not scn_mngr_set:
		connect("scene_manager_set", obj, method)
	else:
		obj.call(method, scene_mngr)

func toggle_pause() -> void:
	set_paused(not(get_tree().paused))
	
func set_paused(stat: bool):
	get_tree().paused = stat
	VisualServer.set_shader_time_scale(0.0 if get_tree().paused else 1.0)
	set_mouse_mode()
	
	if stat:
		emit_signal("paused")
	else:
		emit_signal("unpaused")
		
	emit_signal("pause_changed", stat)

func set_mouse_mode():
	var paused = get_tree().paused
	
	var mode = Input.MOUSE_MODE_VISIBLE if paused else Input.MOUSE_MODE_CAPTURED
	Input.set_mouse_mode(mode)
	if paused:
		var size = get_viewport().size
		get_viewport().warp_mouse(Vector2(size.x/2, (size.y/2)-200))

func quit():
	Settings.save_data()
	get_tree().quit()

func reset_state():
	if player:
		player.unbind_keys()
	set_player(null)
	
func _restart():
	reset_state()
	get_tree().reload_current_scene()
	
func load_scene(path: String, game := true, skip_loading := false):
	Settings.save_data()
	in_game = game
	
	reset_state()
	
	if not skip_loading:
		scene_to_load = path
		print(scene_to_load)
		get_tree().change_scene("res://Scenes/LoadingScene.tscn")
	else:
		get_tree().change_scene(path)
	
func load_hub():
	load_scene("res://Scenes/Scene Hub.tscn", false, true)
