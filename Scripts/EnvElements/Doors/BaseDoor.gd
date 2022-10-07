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

signal start_opening(immediate)
signal opened
signal start_closing(immediate)
signal closed

export(bool) var start_open := false

export(float, .01, 30.0, .01) var time = 1.0
export(float, .2, 10.45, .05) var amount = 1.0
export(TWEEN_TRANSITION) var transition_type = TWEEN_TRANSITION.LINEAR
export(TWEEN_EASE) var ease_type = TWEEN_EASE.OUT
export(AudioStreamOGGVorbis) var slide_sfx = \
	preload("res://Assets/Audio/SFX/door/door_slide2.ogg")
export(float, -80.0, 80.0, .001) var slide_sfx_db = 6.0

var timer := Timer.new()
var audio_player : AudioStreamPlayer3D = null
var is_open := false
var state = STATE.CLOSE

func _ready() -> void:
	if slide_sfx:
		slide_sfx.loop = false
		
		audio_player = AudioStreamPlayer3D.new()
		add_child(audio_player)
		
		audio_player.stream = slide_sfx
		audio_player.unit_db = slide_sfx_db
#		audio_player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_DISABLED
		
		var orig_len = slide_sfx.get_length()
		audio_player.pitch_scale = orig_len / time
		
	add_child(timer)
	timer.connect("timeout", self, "timer_done")
	
	if start_open:
		open(true)

func open(immediate := false):
	_open_close(true, immediate)
	
func close(immediate := false):
	_open_close(false, immediate)
	
func _open_close(_open: bool, immediate := false):
	var sig = "start_opening" if _open else "start_closing"
	var stat = STATE.OPENING if _open else STATE.CLOSING
	
	emit_signal(sig, immediate)
	state = stat
	
	if _open:
		_on_open()
	else:
		_on_closed()
	
	timer.start(0 if immediate else time)
	if (not immediate) and audio_player:
		audio_player.stop()
		audio_player.play()
	
func _on_open():
	pass
	
func _on_closed():
	pass
	
func switch():
	if is_open:
		close()
	else:
		open()

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
	
func _on_deactivated():
	close()
	
func _on_activated():
	open()
