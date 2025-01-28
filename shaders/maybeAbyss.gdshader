shader_type spatial;
render_mode world_vertex_coords;
uniform vec3 shadow_color: source_color; //Color of the shadow(dots)
uniform vec3 hatchColor: source_color;
uniform vec3 back_color: source_color;

uniform float shadow_opacity: hint_range(0, 1); //Opacity multiplier of the shadow
uniform float shadow_max_opacity: hint_range(0, 1); //Maximum opacity of overlapping shadows

uniform float transition_distance: hint_range(0.0, 50.0, 0.1) = 10.0; // Distance threshold
uniform float fade_smoothness: hint_range(0.0, 5.0, 0.1) = 2.0; // Smooth blending

//uniform vec3 luminance: source_color = vec3(0.3086, 0.6049, 0.0820);
uniform float brightness: hint_range(0.1, 20.0, 0.01) = 3.5; //was 0.1 now 1
uniform float hatchBrightness: hint_range(0.1, 20.0, 0.01) = 1.0; //was 0.1 now 1
//uniform float contrast: hint_range(1.0, 4.0, 0.01) = 4.0; //was 2.25
uniform float scale: hint_range(0.0, 2.0, 0.01) = 1.1; //was 0.32
uniform float hatchScale: hint_range(0.0, 2.0, 0.01) = 1.1; //was 0.32
uniform float angle: hint_range(0.0, 6.28, 0.01) = 0.0;
uniform float hatchAngle: hint_range(0.0, 6.28, 0.01) = 0.0;
uniform sampler2D TEXTURE: source_color;
uniform sampler2D hatch1: filter_nearest,repeat_enable;
uniform sampler2D hatch2: filter_nearest,repeat_enable;
uniform sampler2D hatch3: filter_nearest,repeat_enable;
varying vec3 frag_world_position;

mat2 rotate(float a){
	float sa = sin(a);
	float ca = cos(a);
	return mat2(vec2(ca, sa), vec2(-sa, ca));
}

float dotMatrix(vec2 uv) {
	vec2 rotUV = rotate(angle) * uv * scale;
	float pattern = sin(rotUV.y) * sin(rotUV.x);
	return step(0.95, pattern); // 1.0 for dots, 0.0 for spaces
}

float crossHatch(vec2 uv) {
	vec2 rotUV = rotate(hatchAngle) * uv * hatchScale; // Rotate 45 degrees
	vec2 hatch = abs(sin(rotUV));
	float x = step(0.75, hatch.x);
	float y = step(0.95, hatch.y);
	return x+y; // Combine two rotated lines

}

void vertex() {
	frag_world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 resolution = vec2(textureSize(TEXTURE, 0));
	float dotPattern = dotMatrix(FRAGCOORD.xy / resolution);
	float hatchPattern = crossHatch(FRAGCOORD.xy / resolution);
	vec4 texHatch = texture(hatch1, (FRAGCOORD.xy / resolution)*scale);
	vec3 camera_position = (INV_VIEW_MATRIX[3]).xyz;
	float distance_to_camera = distance(camera_position, frag_world_position);

	float t = smoothstep(transition_distance - fade_smoothness, transition_distance + fade_smoothness, distance_to_camera);
	float near_pattern = dotPattern; // Dots for near
	float far_pattern = hatchPattern; // Cross-hatch for far

	//vec3 color = shadow_color * dotPattern;
	vec3 dotColor = vec3(0,0,0); // nonce
	vec3 hatchTex = vec3(0,0,0); //nonce
	//float grey = dot(color, luminance) * contrast;
	if(dotPattern == 1.0){
	dotColor = vec3(shadow_color + dotPattern - 1.0)*brightness;
	} else{
		dotColor = vec3(back_color + dotPattern)*brightness;
	}

	if(hatchPattern == 1.0){
		hatchTex = vec3(hatchColor + hatchPattern)*hatchBrightness;
	}

	vec3 blendedColor = mix(dotColor, hatchTex, t);
	float blended_pattern = mix(near_pattern, far_pattern, t);


	// simple single color albedo.
	ALBEDO = blendedColor;//shadow_color;
	// start with 0 alpha so we can add multiple light shadows together in light()
	ALPHA = blended_pattern;


}

void light() {
	// unshaded lighting
	DIFFUSE_LIGHT = ALBEDO;
	// add alpha based on attenuation, which includes if we're in shadow, cap at our max opacity
	ALPHA = min(ALPHA + shadow_opacity*(1.0 - ATTENUATION), shadow_max_opacity);
}