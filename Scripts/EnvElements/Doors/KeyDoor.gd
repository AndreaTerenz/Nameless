class_name KeyDoor
extends BaseDoor

export(NodePath) var slot_ref

var slot : Slot

func _ready() -> void:
	# wait untile the whole scene is ready to make sure that 
	# get_node isn't called before the slot finishes loading
	# (e.g., the slot is further down in the tree than this door)
	yield(owner, "ready")
	# now if slot == null then it really doesn't exist
	slot = get_node(slot_ref) as Slot
	
	if slot:
		slot.connect("activated", self, "_on_slot_activated")
		
func _on_slot_activated():
	open()

func _on_deactivated():
	pass
	
func _on_activated():
	pass
