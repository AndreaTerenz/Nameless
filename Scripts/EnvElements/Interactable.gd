class_name Interactable
extends Spatial

signal interacted_with(sender)
signal interaction_ended

export(bool) var continuous = false

func entered_range():
	_on_entered_range()
	
func exited_range():
	_on_exited_range()

func interact(sender: Node = null):
	_on_interact(sender)
	emit_signal("interacted_with", sender)
	
func stop_interaction():
	if continuous:
		_on_interact_stop()
		emit_signal("interaction_ended")
	
func _on_interact(sender: Node = null):
	pass

func _on_interact_stop():
	pass

func _on_entered_range():
	print("A")

func _on_exited_range():
	print("B")
