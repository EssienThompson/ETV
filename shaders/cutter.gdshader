// NOTE: Shader automatically converted from Godot Engine 4.3.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_toon, specular_toon, shadows_disabled;

global uniform vec4 borderColor: source_color;
uniform sampler2D _noise;
uniform mat4 cutplane;
varying vec3 wvtx;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform float point_size : hint_range(0.1, 128.0, 0.1);

uniform float roughness : hint_range(0.0, 1.0);
uniform sampler2D texture_metallic : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;

uniform float specular : hint_range(0.0, 1.0, 0.01);
uniform float metallic : hint_range(0.0, 1.0, 0.01);

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
	wvtx = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz;
}

void fragment() {
	vec2 base_uv = UV;

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

	ALBEDO = (mix(borderColor, albedo, borderDist)).rgb;
	EMISSION = (mix(borderColor*5.0, vec4(0.0), borderDist)).rgb;

	//vec4 albedo_tex = texture(texture_albedo, base_uv);
	//ALBEDO = albedo.rgb * albedo_tex.rgb;

	float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	SPECULAR = specular;

	vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
	float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
}
