shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_toon, specular_toon;

uniform vec4 albedo : source_color;
//uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
//uniform float poiint_size : hint_range(0, 128);
//uniform float roughness : hint_range(0, 1);
//uniform vec4 metallic_texture_channel;
//uniform sampler2D texture_roughness : hint_roughness_g, filter_linear_mipmap, repeat_enable;
//uniform float specular;
//uniform float metalic;
//uniform vec3 uv1_scale;
//uniform vec3 uv1_offset;
//uniform vec3 uv2_scale;
//uniform vec3 uv2_offset;

uniform sampler2D color_gradient;
uniform sampler2D fresnel_gradient;


float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}


void vertex() {
	//UV = UV + uv1_scale.xy + uv1_offset.xy;
}


void fragment() {
	float basic_fresnel = fresnel(4.0, NORMAL, VIEW);
	ALBEDO = albedo.rgb + (basic_fresnel * texture(fresnel_gradient, vec2(basic_fresnel, 0.0)).rgb * 1.0);
	
	//vec2 base_uv = UV;
	//vec4 albedo_tex = texture(texture_albedo, base_uv);
	//ALBEDO = albedo.rgb * albedo_tex.rgb + (basic_fresnel * texture(fresnel_gradient, vec2(basic_fresnel, 0.0)).rgb * 1.0);
}


void light() {
	float dotproduct = clamp(dot(NORMAL, LIGHT), -0.9, 0.9);
	float sample = clamp((dotproduct + 1.0) * ATTENUATION / 2.1, 0.05, 0.95);
	vec4 shaded = texture(color_gradient, vec2(sample, 0.0));
	DIFFUSE_LIGHT += clamp((shaded.rgb + LIGHT_COLOR), 0.0, 1.0);
	//DIFFUSE_LIGHT += clamp((shaded.rgb + LIGHT_COLOR), 0.0, 1.0);
}
