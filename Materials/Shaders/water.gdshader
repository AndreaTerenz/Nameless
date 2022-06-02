shader_type spatial;
render_mode cull_disabled;

uniform float noise_scale : hint_range(.5, 80.0) = 1.0;
uniform float time_mult : hint_range(0.0, 6.0) = 4.0;
uniform float fresnel_scale : hint_range(0.0, 2.0) = .05;
uniform float refraction_dampen : hint_range(0.1, 10.0) = 3.0;
uniform bool realistic_murkiness = true;
uniform float murkiness : hint_range(.0, 1.) = .2;

uniform bool enable_edge = true;
uniform float edge_scale : hint_range(0.1, 2.0) = 1.0;
uniform bool smooth_edge = true;
uniform float edge_harshness : hint_range(0.0, 1.0) = 0.5;

uniform sampler2D noise_a;
uniform sampler2D noise_b;
uniform sampler2D noise_normal : hint_normal;

uniform vec4 tint : hint_color = vec4(.13, .29, .57, .61);
uniform vec4 edge_tint : hint_color = vec4(1.0);

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

float rim(float depth) {
	depth = remap_range(depth, 0.0, 1.0, -1.0, 1.0);
	
	float near = .1;
	float far = 25.0;
	
	return (near * far) / (far + depth * (near - far));
}

float noise_sum(vec2 uv, float time) {
	vec3 na_sample = texture(noise_a, uv + time).rgb;
	vec3 nb_sample = texture(noise_b, uv - time).rgb;
	
	return remap_range(na_sample.r + nb_sample.r, 0., 2., -1., 1.);
}

float height(vec2 position, float time) {
	vec2 offset = .1 * vec2(cos(time), sin(time));
	
	return noise_sum((position + offset) / noise_scale, time);
}

vec3 edge_color(sampler2D depth_txt, vec2 uv_pos, vec4 fragcoord) {
	if (enable_edge) {
		float z_depth = (texture(depth_txt, uv_pos).x);
		float z_pos = (fragcoord.z);
		float z_diff = rim(z_depth) - rim(z_pos);
		
		float s = edge_scale / 10.0;
		float edge_mask = step(s, z_diff);
		if (smooth_edge) {
			float h = remap_range(edge_harshness, 0.0, 1.0, -1.0, 1.0);
			edge_mask = smoothstep(s * h, s, z_diff);
		}
		
		return mix(edge_tint.rgb, tint.rgb, edge_mask);
	}
	
	return tint.rgb;
}

float get_clearness(vec2 uv_pos, sampler2D depth_txt, mat4 proj_mat, float vert_z) {
	float depth = texture(depth_txt, uv_pos).r;
		
	depth = remap_range(depth, 0.0, 1.0, -1.0, 1.0);
	depth = proj_mat[3][2] / (depth + proj_mat[2][2]);
	depth += vert_z; //z < 0
	depth = exp(-depth * murkiness);

	return 1.0 - clamp(depth, 0.0, 1.0);
}

vec2 refraction_vec(vec2 uv_pos, float time) {
	float refraction = noise_sum(uv_pos, time / (time_mult * 5.0)) / (refraction_dampen * 15.0);
	return vec2(refraction);
}

void vertex() {
	float noise_x = remap_range(VERTEX.x, -1.0, 1.0, 0.0, 1.0);
	float noise_y = remap_range(VERTEX.z, -1.0, 1.0, 0.0, 1.0);
	
	VERTEX.y += height(vec2(noise_x, noise_y), TIME * time_mult / 10.);
}

float fresnel(vec3 normal, vec3 view) {
	return sqrt(1.0 - dot(normal, view));
}

void fragment() {
	float time = TIME * time_mult / 5.;
	float fr = fresnel(NORMAL, VIEW);
	
	vec2 refract_uv = SCREEN_UV + refraction_vec(UV, time);
	vec3 edge_color = edge_color(DEPTH_TEXTURE, SCREEN_UV, FRAGCOORD);
	float alpha = (!realistic_murkiness) ? tint.a : get_clearness(refract_uv, DEPTH_TEXTURE, PROJECTION_MATRIX, VERTEX.z);
	
	vec4 back = texture(SCREEN_TEXTURE, refract_uv);

	vec3 color = mix(back.rgb, tint.rgb, alpha);
	color = max(color, edge_color);
	
	METALLIC = 0.0;
	RIM = .1;
	NORMALMAP = texture(noise_normal, (UV + time)).rgb;
	ROUGHNESS = .01 * (1.0 - fr);
	ALBEDO.rgb = color + (fresnel_scale * fr);
	SPECULAR = 1.0;
	TRANSMISSION = tint.rgb;
}