extends HSlider

var edit : Settings.SettingsEdit

func _ready() -> void:
	edit = Settings.SettingsEdit.new(Settings.AUDIO, Settings.MASTER_VOL)
	value = edit.current_value
	
	connect("drag_ended",Callable(self,"_on_drag_ended"))

func _on_apply_settings() -> void:
	edit.apply()

func _on_cancel_edits() -> void:
	edit.reset()
	value = edit.current_value

func _on_drag_ended(value_changed: bool) -> void:
	edit.current_value = value
