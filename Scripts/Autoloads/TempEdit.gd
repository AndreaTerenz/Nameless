class_name TempEdit
extends Object

var original_value
var current_value

var changed := false :
	get:
		return changed # TODOConverter40 Copy here content of is_changed 
	set(mod_value):
		mod_value  # TODOConverter40  Non existent set function

func is_changed():
	return current_value != original_value

func _init(orig):
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
