shader_type spatial;
render_mode unshaded, cull_disabled;


uniform sampler2D VIEWPORT_TEXTURE : source_color;


void vertex() {}


void fragment() {
	ALBEDO = texture(VIEWPORT_TEXTURE, SCREEN_UV).xyz;
}

