class_name BasePickup
extends Interactable

export(bool) var permanent = false

func _ready() -> void:
	continuous = false
	interact_txt = "Pick up"

func remove():
	if not permanent:
		queue_free()
