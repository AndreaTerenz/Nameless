extends Area

var target: Interactable = null

func _input(event: InputEvent) -> void:
	if target:
		if target.continuous:
			if Input.is_action_pressed("interact"):
				target.interact()
			elif Input.is_action_just_released("interact"):
				target.stop_interaction()
		elif Input.is_action_just_pressed("interact"):
			target.interact()


func _on_body_entered(body: Node) -> void:
	target = body as Interactable


func _on_body_exited(body: Node) -> void:
	if (body as Interactable) == target:
		if target.continuous:
			target.stop_interaction()
		target = null
