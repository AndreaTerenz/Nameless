extends Area

signal interact_data(data)

var target: Interactable = null

func _input(event: InputEvent) -> void:
	if target and monitoring:
		if target.continuous:
			if Input.is_action_pressed("interact"):
				send_data(target.interact())
			elif Input.is_action_just_released("interact"):
				send_data(target.stop_interaction())
		elif Input.is_action_just_pressed("interact"):
			send_data(target.interact())
				

func send_data(data):
	if data != null:
		emit_signal("interact_data", data)


func _on_body_entered(body: Node) -> void:
	target = body as Interactable
	if target:
		target.entered_range()


func _on_body_exited(body: Node) -> void:
	var intr = body as Interactable
	if intr:
		if intr == target:
			if target.continuous:
				target.stop_interaction()
			target = null
		else:
			intr.exited_range()
