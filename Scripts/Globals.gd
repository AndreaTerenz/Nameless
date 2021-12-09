extends Node

enum GROUPS  {
	ENEMIES,
	PLAYER,
	FRIENDLY
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
