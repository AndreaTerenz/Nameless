class_name Interactable
extends StaticBody3D

signal interacted_with(sender)
signal interaction_ended

@export var enabled: bool = true
@export var one_shot: bool = false
@export var continuous: bool = false
@export var interact_txt: String = ""

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
		
		if (not continuous) and one_shot:
			enabled = false
		
		return output
	
	return null
	
func stop_interaction():
	if continuous:
		var output = _on_interact_stop()
		emit_signal("interaction_ended")
		return output
		
		if one_shot:
			enabled = false
		
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
