class_name TriggerDoor
extends BaseDoor

export(NodePath) var trigger_path

onready var trigger = get_node(trigger_path) as TriggerZone

func _ready() -> void:
	trigger.connect("target_entered", self, "_on_body_entered")
	trigger.connect("target_exited", self, "_on_body_exited")

func _on_body_entered(body: Node) -> void:
	open()

func _on_body_exited(body: Node) -> void:
	close()
