class_name TimerButton
extends Base_Button

export(float) var timer_length = 1.0

onready var timer: Timer = $Timer

func _on_interact(sender: Node = null):
	if timer.is_stopped():
		toggle.active = true
		timer.start(timer_length)

func _on_Timer_timeout() -> void:
	toggle.active = false
