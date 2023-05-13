shader_type canvas_item;

uniform vec4 flash_color : hint_color;
uniform float flash_modifier : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	color.rbg = mix(color.rgb, flash_color.rbg, flash_modifier);
	COLOR = color;
}