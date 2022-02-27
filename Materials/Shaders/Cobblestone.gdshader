shader_type spatial;

uniform float uv_scale = 4.;
uniform vec2 uv_offset = vec2(0.);
uniform float randomness : hint_range(0., 1.) = 1.;
uniform bool show_border = true; 

uniform bool reverse_ridges = false;
uniform float ridge_width : hint_range(0., 1.)  = .5;
uniform float ridge_depth : hint_range(0., 1.) = .5;
uniform float border_thickness : hint_range(0., 1.) = .05;

uniform vec4 tint : hint_color = vec4(.1, .1, .1, 1.0);
uniform vec4 mortar_tint : hint_color = vec4(.05, .05, .05, 1.0);
uniform float metallic = 0.;
uniform float specular = 0.;
uniform float roughness = 1.;

uniform sampler2D noise_normal_text;
uniform float noise_normal_strength : hint_range(0., 1.) = 1.;
uniform float ridge_normal_strength : hint_range(0., 4.) = 1.;

float remap_range(float value, float InputA, float OutputA, float InputB, float OutputB) {
	float lenA = abs(InputA - OutputA);
	float lenB = abs(InputB - OutputB);
	
	float _step = (value - InputA) / lenA;
	
	return OutputA + _step * lenB;
}

bool compare(float v, float target, float delta) {
	return abs(v - target) <= delta/2.0;
}

float smooth_compare(float val, float ref, float delta, float harshness, bool reverse)
{
	float diff = abs(val - ref);
	float output = 1.0 - remap_range(val, delta * harshness, delta, 0.0, 1.0);
	
	output = (!reverse) ? output : 1.0 - output;
	
	return clamp(output, 0., 1.);
}

vec2 RNGV2(vec2 p) {
	vec3 a = fract(vec3(p.x, p.y, p.x) * vec3(1.,3.,4.) * 111.11);
	a += dot(a, a+0.);
	return fract(vec2(a.x*a.y, a.y*a.z) * randomness); //outputs a random vec2 between 0 and 1
}

vec2 stdNormalMap(float height) 
{
    return -vec2(dFdx(height), dFdy(height)) * ridge_normal_strength;
}

float border_mask(vec2 uv) {
	if (show_border) {
		//uv += .5;
		float border = 0.0;
		float bt = (1. - border_thickness);
		
		float border_x = smooth_compare(uv.x, 0., border_thickness, ridge_depth, false);
		if (!compare(uv.x, 0., bt) || !compare(uv.y, 0., bt)) {
			border = 1.;
		}
		
		//border = border_x;
		
		return border;
	}
	
	return 0.;
}

float ridges_mask(float dist) {
	float comp = smooth_compare(dist, .0, ridge_width / 20., 1. - ridge_depth, false);
	
	return clamp(comp, 0., 1.);
}

void fragment()
{
    vec2 value = (UV + uv_offset) * uv_scale;
    
    vec2 baseCell = floor(value);

    //first pass to find the closest cell
    float minDistToCell = 1.0;
    vec2 toClosestCell;
    vec2 closestCell;
    
    for(float x1=-1.; x1<=1.; x1++){
        for(float y1=-1.; y1<=1.; y1++){
            vec2 cell = baseCell + vec2(x1, y1);
            vec2 toCell = cell + RNGV2(cell) - value;
			
            float distToCell = length(toCell);
            if(distToCell < minDistToCell){
                minDistToCell = distToCell;
                closestCell = cell;
                toClosestCell = toCell;
            }
        }
    }
	
    //second pass to find the distance to the closest edge
    float minEdgeDistance = 1.0;
    for(float x2=-1.; x2<=1.; x2++){
        for(float y2=-1.; y2<=1.; y2++){
            vec2 cell = baseCell + vec2(x2, y2);
            vec2 toCell = cell + RNGV2(cell) - value;

            vec2 diffToClosestCell = abs(closestCell - cell);
            bool isClosestCell = diffToClosestCell.x + diffToClosestCell.y < .01;
            if(!isClosestCell){
                vec2 toCenter = (toClosestCell + toCell) * 0.5;
                vec2 cellDifference = normalize(toCell - toClosestCell);
                float edgeDistance = dot(toCenter, cellDifference);
                minEdgeDistance = min(minEdgeDistance, edgeDistance);
            }
        }
    }
	
	minEdgeDistance = clamp(minEdgeDistance, .0, 1.);
	
	float border = border_mask(UV - .5);
	float ridges = ridges_mask(minEdgeDistance);
	float total = clamp(border + ridges, 0., 1.);
	
	ALBEDO = mix(tint.rgb, mortar_tint.rgb, total);
	
	vec3 noise_norm = texture(noise_normal_text, toClosestCell).rgb * noise_normal_strength;
	
	if (reverse_ridges)
		total = 1. - total;
	vec3 ridge_norm = vec3(stdNormalMap((1. - total)), 1.);
	
	NORMALMAP = noise_norm + ridge_norm;
	METALLIC = metallic;
	SPECULAR = specular;
	ROUGHNESS = roughness;
}  