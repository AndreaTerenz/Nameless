# fuck you gdscript
tool
extends "res://Scripts/UI/ProceduralShape.gd"

# class_name ProceduralRectangle
export var width := 10.0 setget set_rect_width
func set_rect_width(value):
	width = value
	update()
	
export var height := 10.0 setget set_rect_height
func set_rect_height(value):
	height = value
	update()

func _ready() -> void:
	pass
	
func _on_draw():
	var size = Vector2(width, height)
	var r = Rect2(-size/2.0, size)
	
	if not stroke_on_top:
		draw_rect(r, stroke, false, stroke_weight, true)
		draw_rect(r, fill, true)
	else:
		draw_rect(r, fill, true)
		draw_rect(r, stroke, false, stroke_weight, true)
	
func get_rect_size():
	return Vector2(width, height)
