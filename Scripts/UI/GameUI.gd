class_name GameUI
extends Control

export(float, 0.0, 3.5, .05) var max_blur = 2.2
export(float, .1, 2.5, .01) var fade_in_len = .5
export(float, .01, .5, .005) var fade_out_len = .1
export(String) var action = ""

var tween : Tween = null
var text_rect : TextureRect = null
var bg_scn : PackedScene = preload("res://Scenes/UI/GameUI_BG.tscn")
var fading_in := false

func _ready() -> void:
	Console.connect("toggled", self, "_on_console_toggle")
	set_paused(false)
	
	tween = Tween.new()
	add_child(tween)
	
	tween.connect("tween_all_completed", self, "_on_tween_done")
	
	text_rect = bg_scn.instance()
	add_child(text_rect)
	move_child(text_rect, 0)
	
func _unhandled_input(event: InputEvent) -> void:
	var action_pressed = Input.is_action_just_pressed(action)
	var console_shown = Console.is_console_shown
	#TEMPORARY
	var is_current_ui = Globals.current_ui in [self, null]
	
	if action_pressed and not console_shown and is_current_ui:
		if not(get_tree().paused):
			_on_pause()
		else:
			_on_unpause()
		
		accept_event()
		
func _on_pause():
	set_paused(true)
	tween_ui(true)
	
func _on_unpause():
	tween_ui(false)
	
func _on_tween_done():
	pass
	
func tween_ui(fade_in : bool):
	if not tween.is_active() and text_rect != null:
		fading_in = fade_in
		var duration : float = fade_in_len if fade_in else fade_out_len
		var trgt_mod_alpha := float(fade_in)
		var trgt_shader_amnt : float = float(fade_in) * max_blur
		
		tween.interpolate_property(self, "modulate:a", \
			null, trgt_mod_alpha, duration, \
			Tween.TRANS_EXPO, Tween.EASE_OUT)
		tween.interpolate_property(text_rect.material, "shader_param/amount", \
			null, trgt_shader_amnt, duration, \
			Tween.TRANS_EXPO, Tween.EASE_OUT)
		tween.start()

func set_paused(val := true) -> void:
	Globals.current_ui = self if val else null
	Globals.set_paused(val)
	visible = val
