shader_type spatial;
render_mode unshaded;

uniform sampler2D mask : hint_white;
uniform sampler2D mask_tex : hint_white;
uniform sampler2D glass_map : hint_normal;
uniform float glass_strength : hint_range(-8.0, 8.0, 0.1) = 1.0;
uniform float blur_strength : hint_range(.0, 8.0, 0.1) = 1.0;

void fragment() {
	vec2 d = texture(glass_map, UV).xy - vec2(0.5);
	vec3 behind = textureLod(SCREEN_TEXTURE, SCREEN_UV + d * glass_strength, blur_strength).rgb;
	
	vec3 mask_tint = texture(mask_tex, UV).rgb;
	float mask_val = texture(mask, UV).r;
	
	ALBEDO = mix(mask_tint, behind, mask_val);
}