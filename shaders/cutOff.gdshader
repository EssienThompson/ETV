shader_type spatial;
render_mode cull_disabled;
uniform sampler2D _albedo: source_color;
global uniform vec4 borderColor: source_color;
uniform sampler2D _noise;
uniform mat4 cutplane;
varying vec3 wvtx;

void vertex() {
	// Called for every vertex the material is visible on.
	wvtx = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz;
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 planeNormal = normalize(-cutplane[1].xyz);
	float planeDistance = dot(planeNormal, cutplane[3].xyz);
	float vertexDistance = dot(planeNormal, wvtx);
	float dist = vertexDistance - planeDistance;

	vec4 clip_pos = PROJECTION_MATRIX * vec4(VERTEX, 1.0);
	vec2 uv = clip_pos.xy/5.0;

	uv += TIME * 0.03;
	float noise = texture(_noise, uv).r;
	dist += noise * 0.03;

	if (dist < 0.0) discard;

	float borderDist = smoothstep(0.0, 0.3, dist);
	vec4 albColor = texture(_albedo, UV);


	ALBEDO = (mix(borderColor, albColor, borderDist)).rgb;
	EMISSION = (mix(borderColor*5.0, vec4(0.0), borderDist)).rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
