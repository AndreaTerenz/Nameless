class_name GameUI
extends Control

export(float, 0.0, 3.5, .05) var max_blur = 2.2
export(float, .05, 2.5, .01) var blur_speed = 1.0

func _ready() -> void:
	Console.connect("toggled", self, "_on_console_toggle")
	set_paused(false)
	
func _target_action():
	return ""
	
func _unhandled_input(event: InputEvent) -> void:
	var action_pressed = Input.is_action_just_pressed(_target_action())
	var console_shown = Console.is_console_shown
	#TEMPORARY
	var is_current_ui = Globals.current_ui in [self, null]
	
	if action_pressed and not console_shown and is_current_ui:
		if not(get_tree().paused):
			_on_pause()
		else:
			_on_unpause()
		
		accept_event()
		
func _on_console_toggle(t):
	if t:
		mouse_filter = MOUSE_FILTER_IGNORE
		release_focus()
	else:
		mouse_filter = MOUSE_FILTER_STOP
		grab_focus()
		
func _on_pause():
	set_paused(true)
	
func _on_unpause():
	set_paused(false)

func set_paused(val := true) -> void:
	Globals.current_ui = self if val else null
	Globals.set_paused(val)
	visible = val
