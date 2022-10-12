class_name KeyDoor
extends BaseDoor

@export var slot_ref: NodePath

var slot : Slot

func _ready() -> void:
	# wait untile the whole scene is ready to make sure that 
	# get_node isn't called before the slot finishes loading
	# (e.g., the slot is further down in the tree than this door)
	await owner.ready
	# now if slot == null then it really doesn't exist
	slot = get_node(slot_ref) as Slot
	
	if slot:
		slot.connect("activated",Callable(self,"_on_slot_activated"))
		
func _on_slot_activated():
	open()

func _on_deactivated():
	pass
	
func _on_activated():
	pass
