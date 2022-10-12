class_name TriggerZone
extends BaseZone

const SAVE_ENTER = 0b01
const SAVE_EXIT = 0b10

@export var save_mode = 0 # (int, FLAGS, "On enter", "On exit")

func group():
	return Globals.TRGGR_ZN_GRP

func _on_entered():
	if save_mode & SAVE_ENTER:
		Globals.player.tracker_save()
		
func _on_exited():
	if save_mode & SAVE_EXIT:
		Globals.player.tracker_save()
