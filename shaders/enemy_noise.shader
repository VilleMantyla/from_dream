shader_type canvas_item;

uniform sampler2D new_texture;
uniform bool play_noise = true;

void fragment() {
	if (play_noise) {
    	COLOR.rgb = texture(new_texture, SCREEN_UV).rgb;
		COLOR.a = texture(TEXTURE, UV).a;
	}
	else {
		vec4 color = texture(TEXTURE, UV);
		//color.rbg = mix(color.rgb, flash_color.rbg, flash_modifier);
		COLOR = color;
	}
}