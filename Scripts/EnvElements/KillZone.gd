class_name KillZone
extends BaseZone

func _ready() -> void:
	super._ready()
	one_shot = false

func group():
	return Globals.KILL_ZN_GRP
