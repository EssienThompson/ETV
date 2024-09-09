shader_type spatial;
render_mode unshaded;

// https://godotshaders.com/shader/sobel-edge-outline-shader-per-object/

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_nearest, repeat_disable;

vec3 convolution(sampler2D tex, vec2 uv, vec2 pixel_size) {
	vec3 conv = vec3(0.0);
	// Gaussian blur kernel
	float gauss[25] = {
		0.00390625, 0.015625, 0.0234375, 0.015625, 0.00390625,
		0.015625, 0.0625, 0.09375, 0.0625, 0.015625, 0.0234375,
		0.09375, 0.140625, 0.09375, 0.0234375, 0.015625,
		0.0625, 0.09375, 0.0625, 0.015625, 0.00390625,
		0.015625, 0.0234375, 0.015625, 0.00390625
	};
	for (int row = 0;  row < 3; row++){
		for (int col = 0;  col < 3; col++){
			//conv += texture(tex, uv + vec2(float(col - 1), float(row - 1)) * pixel_size).rgb;
			conv += texture(tex, uv + vec2(float(col - 2), float(row - 2)) * pixel_size).rgb * gauss[row * 5 + col];
		}
	}
	return conv;
}

void fragment() {
	vec3 pixels[9];
	for (int row = 0;  row < 3; row++){
		for (int col = 0;  col < 3; col++){
			vec2 uv = SCREEN_UV + vec2(float(col - 1), float(row - 1)) * VIEWPORT_SIZE;
			pixels[row * 3 + col] = convolution(SCREEN_TEXTURE, uv, VIEWPORT_SIZE);
		}
	}
	vec3 gx = (
		pixels[0] * -1.0 + pixels[3] * -2.0 + pixels[6] * -1.0
		+ pixels[2] * 1.0 + pixels[5] * 2.0 + pixels[8] * 1.0
	);
	vec3 gy = (
		pixels[0] * -1.0 + pixels[1] * -2.0 + pixels[2] * -1.0
		+ pixels[6] * 1.0 + pixels[7] * 2.0 + pixels[8] * 1.0
	);

	//if (is_edge(uv, screen_normal, offset)) {
		//ALBEDO = outline_color * brightness;
	//} else {
		//ALBEDO = screen_color * brightness;
	//}
	vec3 sobel = sqrt(gx * gx + gy * gy);
	ALBEDO = sobel;
}