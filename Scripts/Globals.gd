extends Node

enum GROUPS  {
	ENEMIES,
	PLAYER,
	FRIENDLY,
	NEUTRAL,
	SUPPLIES
}

enum UI_BTN_THEMES {
	DARK,
	LIGHT
}

const theme_suffix : Dictionary = {
	UI_BTN_THEMES.DARK : "Dark",
	UI_BTN_THEMES.LIGHT : "Light",
}
const default_theme = UI_BTN_THEMES.DARK
var player : Player = null

var scene_triggers : Array = []
var scene_killzones : Array = []

func _ready() -> void:
	Console.add_command("show_triggers", self, "show_triggers")\
	.set_description("toggles triggers visibility")\
	.add_argument("show", TYPE_INT)\
	.register()
	
	Console.add_command("show_killzones", self, "show_killzones")\
	.set_description("toggles killzones visibility")\
	.add_argument("show", TYPE_INT)\
	.register()
	
	Console.add_command("player_info", self, "get_player_info")\
	.set_description("show info about player")\
	.add_argument("mode", TYPE_STRING)\
	.register()
	
	Console.add_command("restart_scene", self, "restart_scene")\
	.set_description("reload current scene")\
	.register()
	
	Console.add_command("set_vsync", self, "set_vsync")\
	.set_description("toggle vsync")\
	.add_argument("use", TYPE_INT)\
	.register()
	
	Console.add_command("get_vsync", self, "get_vsync")\
	.set_description("show vsync status")\
	.register()
	
	Console.add_command("set_windowed", self, "set_window_mode")\
	.set_description("Toggle fullscreen (0) or windowed (1)")\
	.add_argument("mode", TYPE_INT)\
	.register()
	
	Console.add_command("set_resolution", self, "set_resolution")\
	.set_description("Set window resolution (0 0 for default)")\
	.add_argument("width", TYPE_INT)\
	.add_argument("height", TYPE_INT)\
	.register()
	
func show_triggers(t):
	if not show_zones(t, scene_triggers):
		Console.Log.warn("No triggers in scene")
		
func show_killzones(t):
	if not show_zones(t, scene_killzones):
		Console.Log.warn("No killzones in scene")
		
func show_zones(t, zones: Array) -> bool:
	if len(zones) == 0:
		return false
	
	for tr in zones:
		(tr as BaseZone).show_debug_shape = (t != 0)
	return true
		
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
	Console.toggle_console()
	get_tree().reload_current_scene()
		
func set_vsync(t):
	OS.vsync_enabled = (t != 0)
	
func get_vsync():
	Console.write_line(OS.vsync_enabled)
	
func set_window_mode(mode: int):
	OS.window_fullscreen = (mode == 0)
	OS.window_resizable = (mode != 0)
	
func set_resolution(w: int, h: int):
	if (w == 0):
		w = 1920
	if (h == 0):
		h = 1080
		
	OS.window_size = Vector2(w, h)

func toggle_pause(val := 0) -> void:
	if val != 0:
		get_tree().paused = bool(val + 1)
	else:
		get_tree().paused = not(get_tree().paused)
	VisualServer.set_shader_time_scale(0.0 if get_tree().paused else 1.0)

func get_key_btn(key, theme = default_theme) -> String:
	var suffix = theme_suffix[theme]
	return "res://Assets/UI Buttons/Keyboard/%s/%s_Key_%s.png" % [suffix, key, suffix]
	
func get_key_btn_texture(key, theme = default_theme) -> Texture:
	return load(get_key_btn(key, theme)) as Texture

func get_action_btn(action_name, theme = default_theme) -> Texture:
	var action_list = InputMap.get_action_list(action_name)
	var action = action_list[0].as_text() if len(action_list) > 0 else "Blank"
	
	return get_key_btn_texture(action, theme)
