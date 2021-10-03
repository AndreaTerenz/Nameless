extends Node

var health = 50

func _on_attribute_changed(attribute) -> void:
	health = attribute.current_value
	print(attribute.name + ":" + str(attribute.current_value))
