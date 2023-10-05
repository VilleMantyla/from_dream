shader_type spatial;
render_mode unshaded;
render_mode cull_disabled;

uniform sampler2D tex1: hint_albedo;

vec2 scale(vec2 uv, float x, float y)
{
	mat2 scale = mat2(vec2(x, 0.0), vec2(0.0, y));
	
	uv -= 0.5;
	uv = uv * scale;
	uv += 0.5;
	return uv;
}

void fragment(){
	vec2 uv = (SCREEN_UV-0.5)*1.0+0.5;
	ALBEDO = COLOR.xyz * texture(tex1, uv).rgb;
}