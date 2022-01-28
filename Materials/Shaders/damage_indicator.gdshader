shader_type canvas_item;

const float PI = 3.14159265358979323846;
const float TAU = PI * 2.0;
const float PI_HALF = PI / 2.0;
const int SLICES = 8;

uniform float radius = 1.0;
uniform float thickness = .1;
uniform float bg_rim = .1;
uniform vec4 bg_color : hint_color = vec4(.2, .0, .0, 1.0);
uniform vec4 slice_color : hint_color = vec4(1, .2, .0, 1.0);
uniform float slice_min_alpha : hint_range(0.0, 1.0, .01) = 0.0;
uniform float slices_sep = .1;

uniform int angle_bit_mask : hint_range(0, 0xFF, 1) = 0x00;

bool compare(float v, float target, float delta) {
	return abs(v - target) <= delta/2.0;
}

float remap_range(float value, float InputA, float InputB, float OutputA, float OutputB) {
    return(value - InputA) / (InputB - InputA) * (OutputB - OutputA) + OutputA;
}

float smooth_compare(float val, float ref, float delta, float harhsness, bool reverse)
{
	float diff = abs(val-ref);
	float output = remap_range(diff, harhsness/2.0, delta/2.0, 0.0, 1.0);
	
	return (reverse) ? 1.0 - output : output;
}

float angle_gradient(vec2 pos) {
	float a = atan(pos.y, pos.x);
	a = remap_range(a, -PI, PI, 0.0, 1.0);
	a *= float(SLICES);
	
	return a;
}

float ring_mask(vec2 uv_pos) {
	float output = 0.0;
	float len = length(uv_pos);
	
	float t_rim = thickness + bg_rim;
	if (compare(len, radius, t_rim)) {
		output = smooth_compare(len, radius, t_rim, min(bg_rim, .2), true);
		
		if (compare(len, radius, thickness)) {
			output = 1.0;
		}
	}
	
	return output;
}

vec3 ring_colors(vec2 uv_pos) {
	float len = length(uv_pos);
	float a = angle_gradient(uv_pos);
	
	if (compare(fract(a), .5, slices_sep) || !compare(len, radius, thickness)) {
		return bg_color.rgb;
	}
	
	return slice_color.rgb;
}

float slices_mask(vec2 uv_pos) {
	float len = length(uv_pos);
	float a = angle_gradient(uv_pos);
	
	if (angle_bit_mask != 0xFF) {
		int select_mask = 0x01;
		int count = 0;
		
		for (int tmp = angle_bit_mask; tmp > 0; tmp = tmp >> 1) {
			bool bit = bool(tmp & select_mask);
		
			if (bit) {
				if (count != 0) {
					if (compare(a, float(count), 1.0)) {
						return 1.0;
					}
				}
				else {
					if ((compare(a, 0.0, 1.0) || compare(a, 8.0, 1.0))) {
						return 1.0;
					}
				}
			}
			
			count += 1;
		}
	}
	else {
		return 1.0;
	}
	
	return 0.0;
}

void fragment() {
	vec2 pos = UV * 2.0 - vec2(1.0);
	
	COLOR.rgb = ring_colors(pos);
	COLOR.a = ring_mask(pos) * slices_mask(pos);
}