class_name KeyBindsManager
extends Node

func _ready() -> void:
	pass

static func load_binds():
	pass
	
static func action_get_key(act_name : String, idx := 0):
	var action_list = InputMap.action_get_events(act_name)
	idx = abs(idx)
	
	if not action_list.is_empty() and idx < len(action_list):
		return (action_list[idx].scancode)
		
	return -1
	
static func action_get_default_key(act_name : String, idx := 0):
	var proj_action = ProjectSettings.get("input/%s" % act_name)
	
	if proj_action:
		var action_list = proj_action.events
		idx = abs(idx)
		
		if not action_list.is_empty() and idx < len(action_list):
			print((action_list[idx].scancode))
			return (action_list[idx].scancode)
		
	return -1
	
static func action_set_key(act_name : String, scancode : int, idx := 0):
	var action_list = InputMap.action_get_events(act_name)
	idx = abs(idx)
	
	if not action_list.is_empty() and idx < len(action_list):
		action_list[idx].scancode = scancode
		return true
		
	return false

static func action_add_key(act_name : String, scancode : int):
	var action_list = InputMap.action_get_events(act_name)
	var event := InputEventKey.new()
	event.scancode = scancode
	
	InputMap.action_add_event(act_name, event)
