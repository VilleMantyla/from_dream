shader_type canvas_item;

uniform bool play_noise = true;
uniform sampler2D new_texture;

uniform bool color_texutre = true;
uniform vec4 flash_color : hint_color;
uniform float flash_modifier : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	if (play_noise) {
    	COLOR.rgb = texture(new_texture, SCREEN_UV).rgb;
		COLOR.a = texture(TEXTURE, UV).a;
	}
	else if (color_texutre) {
		vec4 color = texture(TEXTURE, UV);
		color.rbg = mix(color.rgb, flash_color.rbg, flash_modifier);
		COLOR = color;
	}
	else {
		vec4 color = texture(TEXTURE, UV);
		//color.rbg = mix(color.rgb, flash_color.rbg, flash_modifier);
		COLOR = color;
	}
}