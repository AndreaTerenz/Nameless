class_name PushButton
extends Base_Button

func _ready() -> void:
	continuous = true
	
func _on_interact(sender: Node = null):
	press()
	
func _on_interact_stop():
	release()
