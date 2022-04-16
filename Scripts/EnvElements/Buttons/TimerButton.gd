class_name TimerButton
extends Base_Button

export(float) var timer_length = 1.0

var timer: Timer = null

func _ready() -> void:
	._ready()
	
	timer = Timer.new()
	add_child(timer)
	
	timer.one_shot = true
	timer.connect("timeout", self, "_on_timeout")

func _on_interact(sender: Node = null):
	if timer.is_stopped():
		toggle.active = true
		timer.start(timer_length)
		press()

func _on_timeout() -> void:
	toggle.active = false
	release()
