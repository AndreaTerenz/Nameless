extends Area

signal pickup_data(data)
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
			
		if (not target) or \
			target.is_queued_for_deletion() or \
			(not target.enabled):
			target_gone()


func send_data(data):
	if data != null:
		if target is BasePickup:
			emit_signal("pickup_data", data)
		else:
			emit_signal("interact_data", data)


func _on_body_entered(body: Node) -> void:
	target = body as Interactable
	if target and target.enabled:
		$InteractTip.show_tip(target.interact_txt)
		target.entered_range()
	# ugly ugly ugly
	if body is Prop and body.grab_enabled:
		$InteractTip.show_tip("Pick up")


func _on_body_exited(body: Node) -> void:
	var intr = body as Interactable
	if intr:
		if intr == target:
			if target.continuous:
				target.stop_interaction()
			target_gone()
		else:
			intr.exited_range()
	# ugly ugly ugly
	if body is Prop:
		$InteractTip.hide_tip()
			
func target_gone():
	$InteractTip.hide_tip()
	target = null

func _on_prop_picked_up(obj) -> void:
	monitoring = false


func _on_prop_released(obj, was_launched) -> void:
	monitoring = true


func diocane(area: Area) -> void:
	print("diocane " + area.name)
