class_name Plate
extends Area

signal pressed
signal released
signal changed(new_state)

export(bool) var reversable = true

var is_up := true
var bodies := []

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")


func _on_body_entered(body: Node) -> void:
	if body is PhysicsBody:
		if len(get_overlapping_bodies()) == 1 and is_up:
			move_plate(false)

func _on_body_exited(body: Node) -> void:
	if reversable and body is PhysicsBody:
		if len(get_overlapping_bodies()) <= 0:
			move_plate(true)

func move_plate(up : bool):
	is_up = up
	
	emit_signal("changed", is_up)
	
	if is_up:
		emit_signal("released")
	else:
		emit_signal("pressed")
	
	_on_move()
	
func _on_move():
	pass
