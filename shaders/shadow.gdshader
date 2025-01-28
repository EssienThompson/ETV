shader_type spatial;
uniform vec3 shadow_color: source_color; //Color of the shadow
uniform vec3 back_color: source_color; //Color of the shadow
uniform float shadow_opacity: hint_range(0, 1); //Opacity multiplier of the shadow
uniform float shadow_max_opacity: hint_range(0, 1); //Maximum opacity of overlapping shadows

//uniform vec3 luminance: source_color = vec3(0.3086, 0.6049, 0.0820);
uniform float brightness: hint_range(0.1, 20.0, 0.01) = 2.0; //was 0.1 now 1
uniform float contrast: hint_range(1.0, 4.0, 0.01) = 2.0; //was 2.25
uniform float scale: hint_range(0.0, 40.0, 0.01) = 30.0; //was 0.08
uniform float angle: hint_range(0.0, 6.28, 0.01) = 3.0;
uniform sampler2D TEXTURE: source_color;
varying vec3 frag_world_position;

mat2 rotate(float a){
	float sa = sin(a);
	float ca = cos(a);
	return mat2(vec2(ca, sa), vec2(-sa, ca));
}

float dotMatrix(vec2 uv) {
	vec2 rotUV = rotate(angle) * uv * scale;
	float pattern = sin(rotUV.y) * sin(rotUV.x);
	return step(0.5, pattern); // 1.0 for dots, 0.0 for spaces
}

void vertex() {
	frag_world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 resolution = vec2(textureSize(TEXTURE, 0));
	vec3 color = texture(TEXTURE, FRAGCOORD.xy/resolution).rgb;
	float dotPattern = dotMatrix(frag_world_position.xz);
	//float grey = dot(shadow_color, luminance) * contrast;
	//color = vec3(grey + dotMatrix(FRAGCOORD.xy * resolution) - 1.0);
	if(dotPattern == 1.0){
		color = vec3(shadow_color + dotPattern - 1.0)*brightness;
	} else{
		color = vec3(back_color  + dotPattern)*brightness;
	}


	// simple single color albedo.
	ALBEDO = color * brightness;//shadow_color;
	// start with 0 alpha so we can add multiple light shadows together in light()
	ALPHA = 0.0;


}

void light() {
	// unshaded lighting
	DIFFUSE_LIGHT = ALBEDO;
	// add alpha based on attenuation, which includes if we're in shadow, cap at our max opacity
	ALPHA = min(ALPHA + shadow_opacity*(1.0 - ATTENUATION), shadow_max_opacity);
}