shader_type spatial;
render_mode blend_mix,unshaded;

uniform sampler2D base_texture : hint_albedo;
uniform sampler2D overlay_texture : hint_albedo;

uniform float scanline_count : hint_range(0, 1800) = 50.0;

uniform vec4 hue: hint_color;
uniform bool flip = false;
uniform bool run = true;
uniform float uv_mult : hint_range(1.0, 50.0, .5) =  8.0;
uniform float lines_speed : hint_range(.1, 2.0, .01) =  .4;
uniform float line_alpha : hint_range(0.0, 1.0, .01) =  .6;
uniform float distortion : hint_range(-1.0, 1.0, .01) =  1.0;
uniform float intensity : hint_range(0.0, 2.0, .01) =  1.0;
uniform float line_definition : hint_range(0.0, 1.0, .01) =  .6;
uniform float min_thickness : hint_range(0.0, 1.0, .01) =  .2;

bool compare(float val, float ref, float delta)
{
	return abs(val-ref) <= delta;
}

float map(float val, float min1, float max1, float min2, float max2)
{
	if (val < min1)
	{
		return min2;
	}
	
	if (val > max1)
	{
		return max2;
	}
	
	float delta1 = (max1-min1);
	float delta2 = (max2-min2);
	
	float scale = delta2/delta1;
	float offset = -min1*scale + min2;
	return val*scale + offset;
}

float smooth_compare(float val, float ref, float delta, float harhsness)
{
	float diff = abs(val-ref);
	
	return map(diff, harhsness/2.0, delta/2.0, 0.0, 1.0);
}

vec2 uv_curve(vec2 uv)
{
	uv = (uv - 0.5) * 2.0;
	
	//You can modify the numbers and try different values
	uv.x *= 1.0 + pow(abs(uv.y) / 3.0, 2.0);
	uv.y *= 1.0 + pow(abs(uv.x) / 3.0, 2.0);
	
	//The scale part (you can delete it when you want)
	uv /= 1.2;
	
	uv = (uv/2.0) + 0.5;
	return uv;
}


void fragment() {
	float coord = fract(UV.y*uv_mult + TIME*lines_speed*float(run));

	float mask = smooth_compare(coord, .5, 1.0 - line_definition, min_thickness);
	if (flip)
	{
		mask = 1.0 - mask;
	}

	float lines_mult = mask + (1.0 - mask)*(1.0 - line_alpha);

	vec2 _uv = UV;
	_uv.x = clamp(_uv.x+(distortion / 100.0)*lines_mult-(1.0/200.0), 0.0, 1.0);

	vec4 base_val = texture(base_texture,_uv);
	vec4 overlay_val = texture(overlay_texture,_uv);
	vec3 final_mult = hue.rgb * lines_mult * intensity;

	ALBEDO = (overlay_val.a == 0.0) ? base_val.rgb : overlay_val.rgb;
	ALBEDO *= final_mult;
}
