shader_type spatial;
render_mode unshaded, cull_disabled;
uniform sampler2D _albedo: source_color;
global uniform vec4 borderColor: source_color;
uniform sampler2D _noise;
uniform mat4 cutplane;
varying vec3 wvtx;

// https://godotshaders.com/shader/sobel-edge-outline-shader-per-object/

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear;
uniform sampler2D NORMAL_TEXTURE: hint_normal_roughness_texture, filter_linear;

uniform float outline_threshold = 0.1; //0.1
uniform vec3 outline_color: source_color = vec3(0.043, 0.282, 0.467);
uniform vec3 screen_color: source_color = vec3(0.043, 0.282, 0.467);
uniform float brightness: hint_range(0.1, 20.0, 0.01) = 6.0; // 6

const mat3 sobel_y = mat3(
	vec3(1.0, 0.0, -1.0),
	vec3(2.0, 0.0, -2.0),
	vec3(1.0, 0.0, -1.0)
);

const mat3 sobel_x = mat3(
	vec3(1.0, 2.0, 1.0),
	vec3(0.0, 0.0, 0.0),
	vec3(-1.0, -2.0, -1.0)
);

bool is_edge(in vec2 uv, in vec3 normal, in vec2 offset) {
	vec3 n = texture(NORMAL_TEXTURE, uv + vec2(0.0, -offset.y)).rgb;
	vec3 s = texture(NORMAL_TEXTURE, uv + vec2(0.0, offset.y)).rgb;
	vec3 e = texture(NORMAL_TEXTURE, uv + vec2(offset.x, 0.0)).rgb;
	vec3 w = texture(NORMAL_TEXTURE, uv + vec2(-offset.x, 0.0)).rgb;
	vec3 nw = texture(NORMAL_TEXTURE, uv + vec2(-offset.x, -offset.y)).rgb;
	vec3 ne = texture(NORMAL_TEXTURE, uv + vec2(offset.x, -offset.y)).rgb;
	vec3 sw = texture(NORMAL_TEXTURE, uv + vec2(-offset.x, offset.y)).rgb;
	vec3 se = texture(NORMAL_TEXTURE, uv + vec2(offset.x, offset.y)).rgb;

	mat3 surrounding_pixels = mat3(
		vec3(length(nw-normal), length(n-normal), length(ne-normal)),
		vec3(length(w-normal), length(normal-normal), length(e-normal)),
		vec3(length(sw-normal), length(s-normal), length(se-normal))
	);

	float edge_x = dot(sobel_x[0], surrounding_pixels[0]) + dot(sobel_x[1], surrounding_pixels[1]) + dot(sobel_x[2], surrounding_pixels[2]);
	float edge_y = dot(sobel_y[0], surrounding_pixels[0]) + dot(sobel_y[1], surrounding_pixels[1]) + dot(sobel_y[2], surrounding_pixels[2]);

	float edge = sqrt(pow(edge_x, 2.0)+pow(edge_y, 2.0));

	return edge > outline_threshold;
}

void vertex() {
	// Called for every vertex the material is visible on.
	wvtx = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz;
}

void fragment() {
	vec2 uv = SCREEN_UV;
	//vec3 screen_color = texture(SCREEN_TEXTURE, uv).rgb;
	vec3 screen_normal = texture(NORMAL_TEXTURE, uv).rgb;
	screen_normal = screen_normal * 2.0 - 1.0;
	vec2 offset = 1.0 / VIEWPORT_SIZE;

	vec3 planeNormal = normalize(-cutplane[1].xyz);
	float planeDistance = dot(planeNormal, cutplane[3].xyz);
	float vertexDistance = dot(planeNormal, wvtx);
	float dist = vertexDistance - planeDistance;

	vec4 clip_pos = PROJECTION_MATRIX * vec4(VERTEX, 1.0);
	vec2 uvo = clip_pos.xy/5.0;

	uvo += TIME * 0.03;
	float noise = texture(_noise, uvo).r;
	dist += noise * 0.03;

	if (dist < 0.0){
		discard;
	}

	float borderDist = smoothstep(0.0, 0.3, dist);
	vec4 albColor = texture(_albedo, UV);
	vec4 screen4 = vec4(screen_color, 1.0);


	//ALBEDO = (mix(borderColor, albColor, borderDist)).rgb;
	//EMISSION = (mix(borderColor*5.0, vec4(0.0), borderDist)).rgb;

	if (is_edge(uv, screen_normal, offset)) {
		ALBEDO = outline_color * brightness;
	} else {
		ALBEDO = ((mix(borderColor, screen4, borderDist)).rgb) * brightness;

		EMISSION = (mix(borderColor*5.0, vec4(0.0), borderDist)).rgb;
	}
}