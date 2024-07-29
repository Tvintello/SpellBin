shader_type canvas_item;

uniform vec2 blur_amount = vec2(0.01, 0.01);
uniform vec2 focus_point = vec2(0.5, 0.5);
uniform float focus_radius = 0.1;
uniform bool blur_background = false;
uniform sampler2D texture2d;
uniform vec2 UV2 = vec2(0.0, 0.0);


void fragment() {
	// Called for every pixel the material is visible on.
	vec4 color = texture(texture2d, UV2);
	vec4 color_up = texture(texture2d, UV2 + vec2(0.0, blur_amount.y));
	vec4 color_down = texture(texture2d, UV2 + vec2(0.0, -blur_amount.y));
	vec4 color_left = texture(texture2d, UV2 + vec2(-blur_amount.x, 0.0));
	vec4 color_right = texture(texture2d, UV2 + vec2(blur_amount.x, 0.0));
	
	COLOR = (color_up + color_down + color_left + color_right) / 4.0;
}

