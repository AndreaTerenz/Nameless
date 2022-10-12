class_name BasePickup
extends Interactable

@export var permanent: bool = false

func _ready() -> void:
	continuous = false
	interact_txt = "Pick up"

func remove_at():
	if not permanent:
		queue_free()
