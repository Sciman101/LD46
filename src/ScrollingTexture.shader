shader_type canvas_item;

uniform vec2 speed;

void fragment() {
	COLOR = texture(TEXTURE, UV+speed*TIME);
}