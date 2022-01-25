class_name Togglable
extends Spatial

signal activated
signal deactivated
signal changed

var active: bool = false setget set_active

func set_active(value):
	active = value
	
	if active:
		_on_activated()
		emit_signal("activated")
	else:
		_on_deactivated()
		emit_signal("deactivated")
		
	_on_active_changed()
	emit_signal("changed")
	
func toggle_active():
	active = not(active)

# Virtual function called upon activation
func _on_activated():
	pass
	
# Virtual function called upon deactivation
func _on_deactivated():
	pass
	
# Virtual function called upon a change in the active state
func _on_active_changed():
	pass
