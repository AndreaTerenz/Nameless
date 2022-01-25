class_name SwitchButton
extends Base_Button

signal switched(on)

func _on_interact(sender: Node = null):
	toggle.active = not(toggle.active)
	pressed = not pressed
	
	if pressed:
		press()
	else:
		release()
	
	emit_signal("switched", pressed)
