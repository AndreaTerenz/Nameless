class_name Interactable
extends StaticBody

signal interacted_with(sender)
signal interaction_ended

export(bool) var enabled = true
export(bool) var continuous = false
export(String) var interact_txt = "Interact"

func _ready():
	Utils.set_layer_bit_in_object(self, "Interactables")

func entered_range():
	_on_entered_range()
	
func exited_range():
	_on_exited_range()

func interact(sender: Node = null):
	if can_interact():
		var output = _on_interact(sender)
		emit_signal("interacted_with", sender)
		
		return output
	
	return null
	
func stop_interaction():
	if continuous:
		var output = _on_interact_stop()
		emit_signal("interaction_ended")
		return output
		
func can_interact():
	return enabled
	
func _on_interact(sender: Node = null):
	pass

func _on_interact_stop():
	pass

func _on_entered_range():
	pass

func _on_exited_range():
	pass
