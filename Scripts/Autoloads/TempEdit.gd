class_name TempEdit
extends Object

var original_value
var current_value

var changed := false setget ,is_changed

func is_changed():
	return current_value != original_value

func _init(orig) -> void:
	original_value = orig
	current_value = original_value
			
func reset():
	current_value = original_value
	changed = false
	_on_reset()
	
func apply():
	if is_changed():
		original_value = current_value
		changed = false
		_on_apply()

func _on_apply():
	pass
	
func _on_reset():
	pass
