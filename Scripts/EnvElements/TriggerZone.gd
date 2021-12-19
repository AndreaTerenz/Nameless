class_name TriggerZone
extends BaseZone

func _set_id():
	zone_id = len(Globals.scene_triggers)
	Globals.scene_triggers.append(self)
