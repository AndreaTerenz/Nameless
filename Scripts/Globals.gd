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
	.register()
	
	Console.add_command("kill_player", self, "kill_player")\
	.set_description("instantly kill player")\
	.register()
	
	Console.add_command("set_vsync", self, "set_vsync")\
	.set_description("toggle vsync")\
	.add_argument("show", TYPE_INT)\
	.register()
	
	Console.add_command("get_vsync", self, "get_vsync")\
	.set_description("show vsync status")\
	.register()
	
func show_triggers(t: int):
	show_zones(t, scene_triggers)
		
func show_killzones(t: int):
	show_zones(t, scene_killzones)
		
func show_zones(t: int, zones: Array):
	for tr in zones:
		(tr as BaseZone).show_debug_shape = (t == 1)
		
func get_player_info():
	if player:
		var origin = player.global_transform.origin
		Console.write_line("Position: [%f, %f, %f]" % [origin.x, origin.y, origin.z])
		Console.write_line("Mode: %s [%d]" % [player.mode_str(), player.mode])
	else:
		Console.write_line("NO PLAYER IN CURRENT SCENE")
		
func kill_player():
	if player:
		player._on_killed()
		Console.toggle_console()
	else:
		Console.write_line("NO PLAYER IN CURRENT SCENE")
		
func set_vsync(t):
	OS.vsync_enabled = (t != 0)
	
func get_vsync():
	Console.write_line(OS.vsync_enabled)

func vec3_horizontal(v: Vector3):
	return Vector2(v.x, v.z)
	
func round_vec2(v : Vector2, digits : int = 3):
	return Vector2(stepify(v.x, pow(10, -digits)), stepify(v.y, pow(10, -digits)))

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
