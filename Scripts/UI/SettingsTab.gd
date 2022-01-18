class_name SettingsTab
extends Tabs

signal apply
signal cancel

export(NodePath) var apply_btn_path = "SettingsPanel/VBoxContainer/PanelContainer/HBoxContainer/ApplySettsBtn"
export(NodePath) var cancel_btn_path = "SettingsPanel/VBoxContainer/PanelContainer/HBoxContainer/CancelSettsBtn"

func _ready() -> void:
	var a_b : Button = get_node(apply_btn_path)
	var c_b : Button = get_node(cancel_btn_path)
	
	a_b.connect("apply_settings", self, "_on_apply_settings")
	c_b.connect("cancel_sett_edits", self, "_on_cancel_edits")
				
func _on_apply_settings() -> void:
	emit_signal("apply")

func _on_cancel_edits() -> void:
	emit_signal("cancel")
