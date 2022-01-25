class_name Interactable
extends StaticBody

signal interacted_with(sender)
signal interaction_ended

export(bool) var continuous = false

func entered_range():
	_on_entered_range()
	
func exited_range():
	_on_exited_range()

func interact(sender: Node = null):
	var output = _on_interact(sender)
	emit_interacted(sender)
	
	return output
	
func stop_interaction():
	if continuous:
		var output = _on_interact_stop()
		emit_interact_end()
		return output
		
func emit_interacted(sender: Node = null):
	emit_signal("interacted_with", sender)
	
func emit_interact_end():
	emit_signal("interaction_ended")
	
func _on_interact(sender: Node = null):
	pass

func _on_interact_stop():
	pass

func _on_entered_range():
	pass

func _on_exited_range():
	pass
