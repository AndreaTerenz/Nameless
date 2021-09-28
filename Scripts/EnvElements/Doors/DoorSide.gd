class_name DoorSide
extends Spatial

export(Vector3) var dir = Vector3.LEFT

var amount: float = 0.0
var mov_delta: Vector3 = Vector3.ZERO
var speed: float = .1
var base_pos: Vector3
var open_pos: Vector3
var current_trgt_pos: Vector3
var open: bool = false setget set_open

func set_open(value):
	open = value

	if open:
		current_trgt_pos = open_pos
	else:
		current_trgt_pos = base_pos

func _ready() -> void:
	yield(owner, "ready")
	base_pos = translation
	current_trgt_pos = translation
	
	mov_delta = dir.normalized() * amount
	open_pos = base_pos + mov_delta

func _process(delta: float) -> void:
	translation = translation.linear_interpolate(current_trgt_pos, speed)
