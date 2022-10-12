class_name DoorSide
extends Node3D

@export var dir: Vector3 = Vector3.LEFT
@export var parent_door_ref: NodePath

var parent_door : BaseDoor = null
var amount: float = 0.0
var tween_time: float = 0.0
var mov_delta: Vector3 = Vector3.ZERO
var tween_trns
var tween_ease
var base_pos: Vector3
var open_pos: Vector3
var current_trgt_pos: Vector3
var open: bool = false :
	get:
		return open # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_open

var tween := Tween.new()

func _ready() -> void:	
	add_child(tween)
	tween.connect("tween_all_completed",Callable(self,"_tween_done"))
	
	var p = get_parent()
	
	if parent_door_ref != "":
		p = get_node(parent_door_ref)
	
	if p is BaseDoor:
		parent_door = p
		
		amount = parent_door.amount
		tween_time = parent_door.time
		tween_trns = parent_door.transition_type
		tween_ease = parent_door.ease_type
		
		parent_door.connect("start_opening",Callable(self,"_on_open"))
		parent_door.connect("start_closing",Callable(self,"_on_close"))
		
		base_pos = position
		current_trgt_pos = position
		
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

func open_close_fx():
	tween.stop_all()
	tween.interpolate_property(self, "position", \
		null, current_trgt_pos, tween_time, \
		tween_trns, tween_ease)
	tween.start()
	
func _tween_done():
	pass
	
func _on_open(imm):
	set_open(true)
	
	if imm:
		position = current_trgt_pos
	else:
		open_close_fx()
	
func _on_close(imm):
	set_open(false)
	
	if imm:
		position = current_trgt_pos
	else:
		open_close_fx()
