// ty https://godotforums.org/d/23079-inverted-blend-on-text/6

shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float intensity : hint_range(0.0, 1.0) = 1.0; 

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 screen_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);
	vec4 texture_color = texture(TEXTURE, UV);
	
	vec3 inverted = 1.0 - screen_color.rgb;
	vec3 final_rgb = mix(screen_color.rgb, inverted, intensity);
	
	COLOR = vec4(final_rgb, texture_color.a);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
