class_name SwitchButton
extends Base_Button

func _on_interact(sender: Node = null):
	if pressed:
		release()
	else:
		press()
