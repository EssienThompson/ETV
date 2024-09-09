shader_type spatial;

uniform sampler2D texture_albedo : source_color;
uniform float blur_size = 0.005; // Adjust this to control the blur amount

void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 color = vec4(0.0);

    // Gaussian kernel weights
    float kernel[5];
    kernel[0] = 0.227027;
    kernel[1] = 0.316216;
    kernel[2] = 0.070270;
    kernel[3] = 0.031329;
    kernel[4] = 0.002748;

    // Sample around the current fragment position in UV space
    for (int i = -2; i <= 2; i++) {
        for (int j = -2; j <= 2; j++) {
            vec2 offset = vec2(float(i) * blur_size, float(j) * blur_size);
            color += texture(texture_albedo, uv + offset) * kernel[abs(i)] * kernel[abs(j)];
        }
    }

    ALBEDO = color.rgb;
}
