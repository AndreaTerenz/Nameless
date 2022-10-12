@tool
extends "res://Scripts/UI/ProceduralShape.gd"

# class_name ProceduralCircle
@export var radius := 20.0 :
	get:
		return radius # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_radius
func set_radius(value):
	radius = value
	update()

func _on_draw() -> void:
	var r_in := radius
	var r_out := radius + stroke_weight / 2.0
	
	if stroke_on_top:
		r_in -= stroke_weight / 2.0
	else:
		r_out += stroke_weight / 2.0
		
	draw_circle(Vector2.ZERO, r_out, stroke)
	draw_circle(Vector2.ZERO, r_in, fill)

func get_rect_size():
	var r_out := radius + stroke_weight / 2.0
	
	if not stroke_on_top:
		r_out += stroke_weight / 2.0
		
	return Vector2.ONE * r_out * 2.0
