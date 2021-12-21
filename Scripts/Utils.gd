extends Node

func vec3_horizontal(v: Vector3):
	return Vector2(v.x, v.z)
	
func round_vec2(v : Vector2, digits : int = 3):
	return Vector2(stepify(v.x, pow(10, -digits)), stepify(v.y, pow(10, -digits)))
