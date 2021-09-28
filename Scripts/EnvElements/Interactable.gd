class_name Interactable
extends Spatial

signal interacted_with(sender)
signal interaction_ended

export(bool) var continuous = false

func interact(sender: Node = null):
	emit_signal("interacted_with", sender)
	_on_interact(sender)
	
func stop_interaction():
	if continuous:
		emit_signal("interaction_ended")
		_on_interact_stop()
	
func _on_interact(sender: Node = null):
	pass

func _on_interact_stop():
	pass
