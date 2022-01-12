class_name SettingsTab
extends Tabs

func _ready() -> void:
	print(get_child_count())
	Settings.connect("settings_loaded", self, "_on_settings_loaded")
	
	if not Settings.data_loaded:
		Settings.load_data()
	else:
		_on_settings_loaded(false)

func _on_settings_loaded(defaults):
	for key in Settings.config.get_section_keys(get_target_section()):
		var val = Settings.config.get_value(get_target_section(), key)
		apply_setting(key, val)
				
func apply_setting(key: String, value):
	pass

func get_target_section():
	return ""
