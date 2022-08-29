class_name DoorSide
extends Spatial

export(Vector3) var dir = Vector3.LEFT

var parent_door : BaseDoor = null
var amount: float = 0.0
var tween_time: float = 0.0
var mov_delta: Vector3 = Vector3.ZERO
var tween_trns
var tween_ease
var base_pos: Vector3
var open_pos: Vector3
var current_trgt_pos: Vector3
var open: bool = false setget set_open

var tween : Tween = null

func _ready() -> void:
	tween = Tween.new()
	add_child(tween)
	tween.connect("tween_completed", self, "_tween_done")
	
	if get_parent() is BaseDoor:
		parent_door = get_parent()
		
		amount = parent_door.amount
		tween_time = parent_door.time
		tween_trns = parent_door.transition_type
		tween_ease = parent_door.ease_type
		
		parent_door.connect("start_opening", self, "_on_open")
		parent_door.connect("start_closing", self, "_on_close")
		
		base_pos = translation
		current_trgt_pos = translation
		
		mov_delta = dir.normalized() * amount
		open_pos = base_pos + mov_delta
	else:
		Console.Log.warn("DoorSide node '%s' isn't child of a BaseDoor node!" % get_path())

func set_open(value):
	open = value

	if open:
		current_trgt_pos = open_pos
	else:
		current_trgt_pos = base_pos
	
	tween.stop_all()
	tween.interpolate_property(self, "translation", \
		null, current_trgt_pos, tween_time, \
		tween_trns, tween_ease)
	tween.start()
	
func _tween_done():
	pass
	
func _on_open():
	set_open(true)
	
func _on_close():
	set_open(false)
