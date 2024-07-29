shader_type spatial;
render_mode unshaded;

uniform sampler2D TEXTURE;

varying vec4 pos;

void vertex() {
	pos = MODELVIEW_MATRIX * PROJECTION_MATRIX * vec4(VERTEX, 1);
}

void fragment() {
	// uv in range 0 to 1 not excluding
	
	vec2 uv = SCREEN_UV;
	ALBEDO = texture(TEXTURE, uv).xyz;
}