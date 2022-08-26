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

var tween : Tween = null

func _ready() -> void:
	tween = Tween.new()
	add_child(tween)

func set_open(value):
	open = value

	if open:
		current_trgt_pos = open_pos
	else:
		current_trgt_pos = base_pos
		
	tween_pos()
		
func tween_pos():
	tween.interpolate_property(self, "translation", \
		null, current_trgt_pos, amount / speed, \
		Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.start()
		
func door_ready(door):
	speed = door.speed / 10.0
	amount = door.amount
	
	door.connect("opened", self, "_on_open")
	door.connect("closed", self, "_on_close")
	
	base_pos = translation
	current_trgt_pos = translation
	
	mov_delta = dir.normalized() * amount
	open_pos = base_pos + mov_delta
	
func _on_open():
	set_open(true)
	
func _on_close():
	set_open(false)
