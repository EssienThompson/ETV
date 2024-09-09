shader_type canvas_item;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable, filter_nearest;
uniform int obj;

vec3 convolution(sampler2D tex, vec2 uv, vec2 pixel_size){
	vec3 conv = vec3(0.0);
	for (int row = 0;  row < 3; row++){
		for (int col = 0;  col < 3; col++){
			conv += texture(tex, uv + vec2(float(col - 1), float(row - 1)) * pixel_size).rgb;
		}
	}
	return conv;
}

void fragment() {
    vec3 pixels[9];
	for (int row = 0;  row < 3; row++){
		for (int col = 0;  col < 3; col++){
			vec2 uv = SCREEN_UV + vec2(float(col - 1), float(row - 1)) * SCREEN_PIXEL_SIZE;
			pixels[row * 3 + col] = convolution(SCREEN_TEXTURE, uv, SCREEN_PIXEL_SIZE);
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
	vec3 sobel = sqrt(gx * gx + gy * gy);
	if (obj == 1){
		COLOR = vec4(sobel, 1.0) * vec4(0.2,0.2,2.75,1);
	}
	else{
		COLOR = vec4(sobel, 1.0);
	}
}

