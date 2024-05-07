shader_type spatial;

uniform vec3 full_color : source_color = vec3(0.0, 1.0, 0.0);
uniform vec3 empty_color : source_color = vec3(1.0, 0.0, 0.0);
uniform float percentage : hint_range(0,1) = 0.5;

varying vec3 vertex_coord;

void vertex() {
	vertex_coord = VERTEX;
}

void fragment() {
	float x = vertex_coord.x + 0.5;
	float percent_along = x / 1.0;
	
	ALBEDO = percentage < percent_along ? empty_color : full_color;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
