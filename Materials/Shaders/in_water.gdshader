shader_type spatial;
render_mode unshaded,cull_front;

uniform vec4 tint : hint_color = vec4(.16, .2, .38, 1.0);
uniform float clarity : hint_range(0.0, 1.0) = .3;

float remap_range(float value, float InputA, float InputB, float OutputA, float OutputB) {
    return(value - InputA) / (InputB - InputA) * (OutputB - OutputA) + OutputA;
}

void fragment() {
	vec3 back = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	float depth = 1.0 - texture(DEPTH_TEXTURE, SCREEN_UV).r;
	
	float inf = 0.0;
	float sup = (1.0 - clarity)/10.0;
	
	float fact = smoothstep(inf, sup, depth);
	
	ALBEDO = mix(back, tint.rgb, 1.0 - fact);
}