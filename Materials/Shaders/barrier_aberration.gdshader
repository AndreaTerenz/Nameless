shader_type spatial;
render_mode cull_disabled, unshaded;

uniform vec4 tint : hint_color = vec4(.16, .2, .38, 1.0);
uniform vec4 edge_tint : hint_color = vec4(1.0);
uniform sampler2D noise_txt;

uniform bool enable_edge = true;
uniform float edge_scale : hint_range(0.1, 2.0) = 1.0;
uniform bool smooth_edge = true;
uniform float edge_harshness : hint_range(0.0, 1.0) = 0.5;

uniform float screen_abr_amnt = 1.0;

uniform float white_noise_strength = .05;

//get a scalar random value from a 3d value
float rand(vec3 value){
    //make value smaller to avoid artefacts
    vec3 smallValue = sin(value);
    //get scalar value from 3d vector
    float random = dot(smallValue, vec3(12.9898, 78.233, 37.719));
    //make value more random by making it bigger and then taking teh factional part
    random = fract(sin(random) * 143758.5453);
    return random;
}

//get a scalar random value from a 3d value
float rand3dTo1d(vec3 value, vec3 dotDir){
    //make value smaller to avoid artefacts
    vec3 smallValue = sin(value);
    //get scalar value from 3d vector
    float random = dot(smallValue, dotDir);
    //make value more random by making it bigger and then taking teh factional part
    random = fract(sin(random) * 143758.5453);
    return random;
}

//get a 3d random value from a 3d value
vec3 rand3dTo3d(vec3 value){
    return vec3(
        rand3dTo1d(value, vec3(12.989, 78.233, 37.719)),
        rand3dTo1d(value, vec3(39.346, 11.135, 83.155)),
        rand3dTo1d(value, vec3(73.156, 52.235, 09.151))
    );
}

float remap_range(float value, float InputA, float InputB, float OutputA, float OutputB) {
    return(value - InputA) / (InputB - InputA) * (OutputB - OutputA) + OutputA;
}

float rim(float depth) {
	depth = remap_range(depth, 0.0, 1.0, -1.0, 1.0);
	
	float near = .1;
	float far = 25.0;
	
	return (near * far) / (far + depth * (near - far));
}

vec4 edge_color(sampler2D depth_txt, vec2 uv_pos, vec4 fragcoord, vec4 main_tint) {
	float z_depth = (texture(depth_txt, uv_pos).x);
	float z_pos = (fragcoord.z);
	float z_diff = rim(z_depth) - rim(z_pos);
	
	float s = edge_scale / 10.0;
	float edge_mask = step(s, z_diff);
	if (smooth_edge) {
		float h = remap_range(edge_harshness, 0.0, 1.0, -1.0, 1.0);
		edge_mask = smoothstep(s * h, s, z_diff);
	}
	
	return mix(edge_tint, main_tint, edge_mask);
}

void fragment() {
	vec3 back = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	float depth = 1.0 - texture(DEPTH_TEXTURE, SCREEN_UV).r;
	
	float noise = texture(noise_txt, vec2(TIME)).r;
	
	float adjusted_screen_abr_amnt = noise / 100.0;
	vec4 t;
	t.r = texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x + adjusted_screen_abr_amnt, SCREEN_UV.y)).r;
	t.g = texture(SCREEN_TEXTURE, SCREEN_UV).g;
	t.b = texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x - adjusted_screen_abr_amnt, SCREEN_UV.y)).b;
	
	vec4 edge = edge_color(DEPTH_TEXTURE, SCREEN_UV, FRAGCOORD, tint + t);
	
	ALPHA = edge.a;
	ALBEDO = edge.rgb;
	//EMISSION = tint.rgb;
	
	float white_noise = rand3dTo3d(floor(VERTEX*20.) + .002*TIME).r*white_noise_strength;
	ALBEDO += white_noise;
}