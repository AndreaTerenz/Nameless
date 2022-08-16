tool
extends Control

#class_name ProceduralShape

export(Color) var fill := Color.white setget set_fill
export(Color) var stroke := Color.black setget set_stroke
export(float, 0.0, 100.0, .1) var stroke_weight := 4.0 setget set_stroke_weight

export(bool) var stroke_on_top = true setget set_stroke_on_top
export(bool) var pivot_centered := true setget set_centered
export(bool) var keep_size := false setget set_keep_size

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
		rect_size = get_rect_size()
		rect_min_size = rect_size
	
	rect_pivot_offset = rect_size/2.0 if pivot_centered else Vector2.ZERO
		
	var center := rect_size/2.0
	draw_set_transform(center, 0.0, Vector2.ONE)
	
	_on_draw()

func _on_draw():
	pass

func get_rect_size():
	return Vector2.ONE
