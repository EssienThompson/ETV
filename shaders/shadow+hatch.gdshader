shader_type spatial;
render_mode world_vertex_coords, depth_draw_always, cull_disabled;

uniform vec3 shadow_color: source_color; //Color of the shadow(dots)
uniform vec3 hatchColor: source_color;
uniform vec3 farShadowColor: source_color;
uniform vec3 back_color: source_color;
uniform vec3 HBack_color: source_color;
uniform vec3 FSBackColor: source_color;

uniform bool obj = false;
uniform bool chara = false;

uniform float shadow_opacity: hint_range(0, 1) = 1.0; //Opacity multiplier of the shadow
uniform float shadow_max_opacity: hint_range(0, 1) = 1.0; //Maximum opacity of overlapping shadows

uniform float transition_distance: hint_range(0.0, 50.0, 0.1) = 10.0; // Distance threshold
uniform float fade_smoothness: hint_range(0.0, 5.0, 0.1) = 2.0; // Smooth blending

//uniform vec3 luminance: source_color = vec3(0.3086, 0.6049, 0.0820);
uniform float brightness: hint_range(0.1, 20.0, 0.01) = 3.5; //was 0.1 now 1
uniform float hatchBrightness: hint_range(0.1, 20.0, 0.01) = 0.9; //was 0.1 now 1
uniform float FarShadowBrightness: hint_range(0.1, 20.0, 0.01) = 0.9;
//uniform float contrast: hint_range(1.0, 4.0, 0.01) = 4.0; //was 2.25
uniform float scale: hint_range(0.0, 400.0, 0.01) = 20; //was 14
uniform float hatchScale: hint_range(0.0, 200.0, 0.01) = 5.25; //was 0.32
uniform float FarShadowScale: hint_range(0.0, 40.0, 0.01) = 30;
uniform float angle: hint_range(0.0, 6.28, 0.01) = 0.0;
uniform float hatchAngle: hint_range(0.0, 6.28, 0.01) = 0.65;
uniform sampler2D TEXTURE: source_color;
varying vec3 frag_world_position;
varying vec3 vertexPos;
varying vec3 pix;

mat2 rotate(float a){
	float sa = sin(a);
	float ca = cos(a);
	return mat2(vec2(ca, sa), vec2(-sa, ca));
}

float dotMatrix(vec2 uv, float stepHold) {
	vec2 rotUV = rotate(angle) * uv * scale;
	float pattern = sin(rotUV.y) * sin(rotUV.x);
	return step(stepHold, pattern); // 1.0 for dots, 0.0 for spaces
}

float crossHatch(vec2 uv, float stepHold) {
	vec2 rotUV = rotate(hatchAngle) * uv * hatchScale; // Rotate 45 degrees
	vec2 hatch = abs(sin(rotUV));
	float x = step(stepHold, hatch.x);
	float y = step(stepHold, hatch.y);
	return x+y; // Combine two rotated lines

}

void vertex() {
	frag_world_position = ((MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz);
	vertexPos = (inverse(MODEL_MATRIX) * vec4(VERTEX, 1.0)).xyz;
	pix = (VIEW_MATRIX * MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	VERTEX += NORMAL * 0.001;
}

void fragment() {
	vec2 resolution = vec2(textureSize(TEXTURE, 0));
	//vec3 world_pos = (INV_PROJECTION_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec2 uv = frag_world_position.xz;
	float hatchStep = 0.0;
	vec3 camera_position = CAMERA_POSITION_WORLD;
	float distance_to_camera = distance(camera_position, frag_world_position);
	if (obj == true){
		uv = UV;//frag_world_position.yz + frag_world_position.xy + uv;
		hatchStep = 0.999;
		distance_to_camera = distance(camera_position, NODE_POSITION_WORLD);
	}
	if(chara == true){
		uv = UV;
		hatchStep = 0.99;
		distance_to_camera = distance(camera_position, NODE_POSITION_WORLD);
	}
	vec2 Ouv = UV;//FRAGCOORD.xy / resolution;
	float dotPattern = dotMatrix(uv, 0.95);
	float OdotPattern = dotMatrix(Ouv, 0.95);
	float farDotPattern = dotMatrix(uv, 0.5);
	float hatchPattern = crossHatch(uv, hatchStep);
	vec3 tempCam = (INV_PROJECTION_MATRIX * vec4(VERTEX, 1.0)).xyz;

	float t = smoothstep(transition_distance - fade_smoothness, transition_distance + fade_smoothness, distance_to_camera);
	//float near_pattern = dotPattern; // Dots for near
	//float far_pattern = hatchPattern; // Cross-hatch for far
	//float blended_pattern = mix(near_pattern, far_pattern, t);

	//vec3 color = shadow_color * dotPattern;
	vec3 dotTex = vec3(0,0,0); // nonce
	vec3 hatchTex = vec3(0,0,0); //nonce
	vec3 farDotTex = vec3(0,0,0); //nonce
	vec3 blendedColor = vec3(0,0,0);
	//float grey = dot(color, luminance) * contrast;
	if(dotPattern == 1.0){
		dotTex = vec3(shadow_color + dotPattern - 1.0)*brightness;
	} else{
		dotTex = vec3(back_color  + dotPattern)*brightness;
	}

	if(hatchPattern == 1.0){
		hatchTex = vec3(hatchColor + hatchPattern - 1.0)*hatchBrightness;
	} else{
		hatchTex = vec3(HBack_color  + hatchPattern)*brightness;
	}

	if(farDotPattern == 1.0){
		farDotTex = vec3(farShadowColor + farDotPattern - 1.0);
	} else{
		farDotTex = vec3(FSBackColor  + farDotPattern);
	}

	if (obj == true || chara == true){
		blendedColor = mix(dotTex, hatchTex, t);
	} else{
		blendedColor = mix(dotTex, farDotTex, t);
	}



	// simple single color albedo.
	ALBEDO = blendedColor;
	// start with 0 alpha so we can add multiple light shadows together in light()
	ALPHA = 0.0;


}

void light() {
	// unshaded lighting
	DIFFUSE_LIGHT = ALBEDO;
	// add alpha based on attenuation, which includes if we're in shadow, cap at our max opacity
	ALPHA = min(ALPHA + shadow_opacity*(1.0 - ATTENUATION), shadow_max_opacity);
}