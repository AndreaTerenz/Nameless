tool
extends TextureRect

export(String) var action = ""
export(float, .1, 2.0, .05) var scaling = .6 setget set_scaling

func set_scaling(newVal):
	scaling = newVal
	_update_image()

func _ready() -> void:
	_update_image()
	
func _update_image():
	var txt_img : Image = get_action_btn(action)
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
	var action_list = InputMap.get_action_list(action_name)
	
	if len(action_list) > 0:
		if not(idx in range(0, len(action_list))):
			idx = 0

		var target_action = action_list[idx]
		
		if target_action is InputEventMouseButton:
			var btn := "Simple"
			match target_action.button_index:
				BUTTON_LEFT:
					btn = "Left"
				BUTTON_RIGHT:
					btn = "Right"
				BUTTON_MIDDLE:
					btn = "Middle"
					
			return get_mouse_btn_texture(btn, theme)
			
		elif target_action is InputEventKey:
			var txt = target_action.as_text()
			
			if txt == "<":
				txt = "Mark_Left"
			elif txt == ">":
				txt = "Mark_Right"
				
			return get_key_btn_texture(txt, theme) 
	
	return get_key_btn_texture("Blank", theme)
