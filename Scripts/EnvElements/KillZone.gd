class_name KillZone
extends BaseZone

func _set_id():
	zone_id = len(Globals.scene_killzones)
	Globals.scene_killzones.append(self)

func group():
	return Globals.KILL_ZN_GRP
