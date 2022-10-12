@tool
extends Control

#class_name ProceduralShape

@export var fill: Color := Color.WHITE :
	get:
		return fill # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_fill
@export var stroke: Color := Color.BLACK :
	get:
		return stroke # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_stroke
@export var stroke_weight := 4.0 setget set_stroke_weight # (float, 0.0, 100.0, .1)

@export var stroke_on_top: bool = true :
	get:
		return stroke_on_top # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_stroke_on_top
@export var pivot_centered: bool := true :
	get:
		return pivot_centered # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_centered
@export var keep_size: bool := false :
	get:
		return keep_size # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_keep_size

func set_stroke(value):
	stroke = value
	update()

func set_fill(value):
	fill = value
	update()
	
func set_stroke_weight(value):
	stroke_weight = value
	update()
	
func set_stroke_on_top(value):
	stroke_on_top = value
	update()
	
func set_centered(value):
	pivot_centered = value
	update()
	
func set_keep_size(value):
	keep_size = value
	update()

func _draw() -> void:
	if not keep_size:
		size = get_rect_size()
		minimum_size = size
	
	pivot_offset = size/2.0 if pivot_centered else Vector2.ZERO
		
	var center := size/2.0
	draw_set_transform(center, 0.0, Vector2.ONE)
	
	_on_draw()

func _on_draw():
	pass

func get_rect_size():
	return Vector2.ONE
