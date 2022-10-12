@tool
extends TextureRect

@export var action: String = "" :
	get:
		return action # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_action
@export var key_override: String = "" :
	get:
		return key_override # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_override
@export var scaling = .6 setget set_scaling # (float, .1, 2.0, .05)

func set_scaling(newVal):
	scaling = newVal
	_update_image()
	
func set_override(newVal):
	key_override = newVal
	_update_image()
	
func set_action(newVal):
	action = newVal
	_update_image()

func _ready() -> void:
	_update_image()
	
func _update_image():
	var txt_img : Image = null
	
	if key_override == "":
		txt_img = get_action_btn(action)
	else:
		txt_img = get_key_btn_texture(key_override)
	
	var size : Vector2 = txt_img.get_size() * scaling
	txt_img.resize(size.x, size.y)
	
	var txt := ImageTexture.new()
	txt.create_from_image(txt_img)
	
	texture = txt

func get_btn_path(key, file_fmt_str: String, device: String, theme = Globals.UI_BTN_THEME) -> String:
	var suffix = Globals.THEMES_SUFFIX[theme]
	file_fmt_str = file_fmt_str % [key, suffix]
	return "%s/%s/%s/%s.png" % [Globals.UI_BTN_BASE_DIR, device, suffix, file_fmt_str]

func get_key_btn_path(key, theme = Globals.UI_BTN_THEME) -> String:
	return get_btn_path(key, "%s_Key_%s", "Keyboard", theme)
	
func get_mouse_btn_path(key, theme = Globals.UI_BTN_THEME) -> String:
	return get_btn_path(key, "Mouse_%s_Key_%s", "Mouse", theme)
	
func get_key_btn_texture(key, theme = Globals.UI_BTN_THEME) -> Image:
	return load(get_key_btn_path(key, theme)).get_data()
	
func get_mouse_btn_texture(key, theme = Globals.UI_BTN_THEME) -> Image:
	return load(get_mouse_btn_path(key, theme)).get_data()

func get_action_btn(action_name, theme := Globals.UI_BTN_THEME, idx := 0) -> Image:
	var action_list := []
	
	if Engine.editor_hint:
		var proj_act_list = ProjectSettings.get("input/%s" % action_name)
		if proj_act_list:
			action_list = proj_act_list.events
	else:
		action_list = InputMap.action_get_events(action_name)
	
	if len(action_list) > 0:
		if not(idx in range(0, len(action_list))):
			idx = 0

		var target_action = action_list[idx]
		
		if target_action is InputEventMouseButton:
			var btn := "Simple"
			
			match target_action.button_index:
				MOUSE_BUTTON_LEFT:
					btn = "Left"
				MOUSE_BUTTON_RIGHT:
					btn = "Right"
				MOUSE_BUTTON_MIDDLE:
					btn = "Middle"
					
			return get_mouse_btn_texture(btn, theme)
			
		elif target_action is InputEventKey:
			var txt = target_action.as_text()
			
			match txt:
				"<":
					txt = "Mark_Left"
				">":
					txt = "Mark_Right"
				"Control":
					txt = "Ctrl"
				"Escape":
					txt = "Esc"
				
			return get_key_btn_texture(txt, theme) 
	
	return get_key_btn_texture("Blank", theme)
