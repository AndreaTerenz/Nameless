class_name KillZone
extends BaseZone

func _ready() -> void:
	._ready()
	oneshot = false

func group():
	return Globals.KILL_ZN_GRP
