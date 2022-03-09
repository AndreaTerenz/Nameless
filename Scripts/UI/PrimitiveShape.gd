tool
extends Control

enum PRIMITIVES {
	CIRCLE,
	RECTANGLE,
	ELLIPSE,
}

export(PRIMITIVES) var type setget set_type

export var fill := Color.white setget set_fill
export var stroke := Color.black setget set_stroke
export var stroke_weight := 4.0 setget set_stroke_weight

func _get_property_list():
	match type:
		PRIMITIVES.CIRCLE:
			return [
				{
					"name": "radius",
					"type": TYPE_REAL,
					"string_hint": "float"
				}
			]
		PRIMITIVES.ELLIPSE:
			return [
				{
					"name": "major",
					"type": TYPE_REAL,
					"string_hint": "float"
				},
				{
					"name": "minor",
					"type": TYPE_REAL,
					"string_hint": "float"
				}
			]
		PRIMITIVES.RECTANGLE:
			return [
				{
					"name": "width",
					"type": TYPE_REAL,
					"string_hint": "float"
				},
				{
					"name": "height",
					"type": TYPE_REAL,
					"string_hint": "float"
				}
			]
	
	return []
	
func set_type(value):
	type = value
	property_list_changed_notify()
	update()

func set_stroke(value):
	stroke = value
	update()

func set_fill(value):
	fill = value
	update()
	
func set_stroke_weight(value):
	stroke_weight = value
	update()

var radius := 20.0 setget set_radius
func set_radius(value):
	radius = value
	update()
	
var width := 10.0 setget set_rect_width
func set_rect_width(value):
	width = value
	update()
	
var height := 10.0 setget set_rect_height
func set_rect_height(value):
	height = value
	update()
	
var major := 20.0 setget set_major
func set_major(value):
	major = value
	update()
	
var minor := 20.0 setget set_minor
func set_minor(value):
	minor = value
	update()

func _draw() -> void:
	var center := rect_size/2.0
	draw_set_transform(center, 0.0, Vector2.ONE)
	
	match type:
		PRIMITIVES.CIRCLE:
			draw_circle(Vector2.ZERO, radius, fill)
			draw_arc(Vector2.ZERO, radius, 0.0, 2*PI, 64, stroke, stroke_weight, true)
		PRIMITIVES.RECTANGLE:
			var size = Vector2(width, height)
			var r = Rect2(-size/2.0, size)
			
			draw_rect(r, stroke, false, stroke_weight, true)
			draw_rect(r, fill, true)
		PRIMITIVES.ELLIPSE:
			var scale = Vector2(minor/major, 1.0)
			draw_set_transform(center, 0.0, scale)
			draw_circle(Vector2.ZERO, radius, fill)
			draw_arc(Vector2.ZERO, radius, 0.0, 2*PI, 64, stroke, stroke_weight, true)
