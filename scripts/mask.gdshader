shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec4 masking_color : source_color;
uniform float masking_range = 0.1;
 
void fragment()
{
	vec4 world_pixel = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	if (length(abs(masking_color - world_pixel)) <= masking_range)
	{
		discard;
	}
}