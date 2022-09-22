class_name BaseDoor
extends Togglable

# PORCALAMADONNA DIOBOIA
enum TWEEN_TRANSITION {
	LINEAR = 0,
	SINE = 1,
	QUINT = 2,
	QUART = 3,
	QUAD = 4,
	EXPO = 5,
	ELASTIC = 6,
	CUBIC = 7,
	CIRC = 8,
	BOUNCE = 9,
	BACK = 10,
}

# PORCALAMADONNA DIOBOIA PT 2
enum TWEEN_EASE {
	IN = 0,
	OUT = 1,
	IN_OUT = 2,
	OUT_IN = 3
}

enum STATE {
	OPEN,
	OPENING,
	CLOSE,
	CLOSING
}

signal start_opening
signal opened
signal start_closing
signal closed
signal forced_stop

export(bool) var start_open := false

export(float, .01, 30.0, .01) var time = 1.0
export(float, .2, 10.45, .05) var amount = 1.0
export(TWEEN_TRANSITION) var transition_type = TWEEN_TRANSITION.LINEAR
export(TWEEN_EASE) var ease_type = TWEEN_EASE.OUT

var timer := Timer.new()
var is_open := false
var state = STATE.CLOSE

func _ready() -> void:
	if start_open:
		open()
	add_child(timer)
	timer.connect("timeout", self, "timer_done")

func open():
	emit_signal("start_opening")
	_on_open()
	
	state = STATE.OPENING
	timer.start(time)
	
func timer_done():
	match state:
		STATE.OPENING:
			state = STATE.OPEN
			is_open = true
			emit_signal("opened")
		STATE.CLOSING:
			state = STATE.CLOSE
			is_open = false
			emit_signal("closed")
	
func _on_open():
	pass
	
func close():
	emit_signal("start_closing")
	_on_closed()
	
	state = STATE.CLOSING
	timer.start(time)
	
func _on_closed():
	pass
	
func switch():
	if is_open:
		close()
	else:
		open()
	
func _on_deactivated():
	close()
	
func _on_activated():
	open()
