shader_type canvas_item;

void fragment(){
	//vec2 noise_uv = vec2(UV.x +TIME, UV.y+TIME);
	//COLOR.rgba = texture(TEXTURE, noise_uv + TEXTURE_PIXEL_SIZE).rgba;
	COLOR = texture(TEXTURE, UV + TEXTURE_PIXEL_SIZE + TIME).rgba;
	
}