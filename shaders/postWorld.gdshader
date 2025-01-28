shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_toon, specular_toon, shadows_disabled, unshaded;

global uniform vec4 borderColor: source_color;
uniform sampler2D _noise;

uniform vec4 albedo : source_color;

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear;
uniform sampler2D NORMAL_TEXTURE: hint_normal_roughness_texture, filter_linear;

uniform float outline_threshold = 0.1; //0.1
uniform vec3 outline_color: source_color = vec3(1, 1, 1);
uniform float brightness: hint_range(0.1, 20.0, 0.01) = 1.0; // 6

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
	//POSITION = vec4(VERTEX.xy,1.0,1.0); //use quad for camera
}

void fragment() {
	vec2 uvScr = SCREEN_UV;
	vec3 screen_color = texture(SCREEN_TEXTURE, uvScr).rgb;
	vec3 screen_normal = texture(NORMAL_TEXTURE, uvScr).rgb;
	screen_normal = screen_normal * 2.0 - 1.0;
	vec2 offset = 1.0 / VIEWPORT_SIZE;
	vec3 bedo = screen_color * brightness;
	vec4 al = vec4(bedo,1);

	if (is_edge(uvScr, screen_normal, offset)) {
		ALBEDO = outline_color * brightness;
	} else {
		ALBEDO = albedo.rgb;
	}

	//EMISSION = (mix(borderColor*5.0, vec4(0.0), borderDist)).rgb;

}
