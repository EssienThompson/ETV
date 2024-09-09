shader_type canvas_item;

uniform vec3 luminance: source_color = vec3(0.3086, 0.6049, 0.0820);
uniform float brightness: hint_range(0.1, 20.0, 0.01) = 2.0;
uniform float contrast: hint_range(1.0, 4.0, 0.01) = 2.0;
uniform float scale: hint_range(0.0, 2.0, 0.01) = 1.0;
uniform float angle: hint_range(0.0, 6.28, 0.01) = 3.0;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable, filter_nearest;

mat2 rotate(float a){
	float sa = sin(a);
	float ca = cos(a);
	return mat2(vec2(ca, sa), vec2(-sa, ca));
}

float dotMatrix(vec2 uv) {
	vec2 rotUV = rotate(angle) * uv * scale;
	return sin(rotUV.y) * sin(rotUV.x);
}

void fragment() {
	vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;
	vec3 color = texture(SCREEN_TEXTURE, UV).rgb;
	float grey = dot(color, luminance) * contrast;
	color = vec3(grey + dotMatrix(SCREEN_UV * resolution) - 1.0);
	COLOR = vec4(color * brightness, 1.0);
}
