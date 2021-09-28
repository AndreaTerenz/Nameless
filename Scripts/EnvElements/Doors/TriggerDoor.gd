class_name TriggerDoor
extends BaseDoor

export(NodePath) var trigger_path

onready var trigger = get_node(trigger_path) as Area

func _ready() -> void:
	trigger.connect("body_entered", self, "_on_body_entered")
	trigger.connect("body_exited", self, "_on_body_exited")

func _on_body_entered(body: Node) -> void:
	print("AAAAAAAAAAAAAAA")
	open()

func _on_body_exited(body: Node) -> void:
	print("AAAAAAAAAAAAAAA")
	close()
