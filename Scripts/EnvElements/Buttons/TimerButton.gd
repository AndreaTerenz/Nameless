class_name TimerButton
extends Base_Button

@export var timer_length: float = 1.0

var timer: Timer = null

func _ready() -> void:
	super._ready()
	
	timer = Timer.new()
	add_child(timer)
	
	timer.one_shot = true
	timer.connect("timeout",Callable(self,"_on_timeout"))

func _on_interact(sender: Node = null):
	if timer.is_stopped():
		timer.start(timer_length)
		press()

func _on_timeout() -> void:
	release()
