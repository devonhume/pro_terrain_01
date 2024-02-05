shader_type spatial;
uniform sampler2D grass_texture:source_color;
uniform sampler2D rock_texture:source_color;
uniform sampler2D sand_texture:source_color;

uniform float min_rock_slope:hint_range(0.,1.,0.01) = 0.5;
uniform float max_grass_slope:hint_range(0.,1.,0.01) = 0.9;
uniform float min_rockgrass_height = 1.0;
uniform float max_sand_height = 1.5;
uniform float uv_multiplier = 1.0;

varying float normal_y;
varying float vertex_y;
			
void vertex(){
	normal_y = NORMAL.y;
	vertex_y = VERTEX.y;
}

void fragment(){
	//Albedo Values
	vec3 grass_albedo = texture(grass_texture,UV*uv_multiplier).xyz;
	vec3 rock_albedo = texture(rock_texture,UV*uv_multiplier).xyz;
	vec3 sand_albedo = texture(sand_texture,UV*uv_multiplier).xyz;

	//Weights
	//float rock_grass_weight = (INV_VIEW_MATRIX*vec4(NORMAL,0.)).y;
	float rock_grass_weight = normal_y;
	float sand_rockgrass_weight = vertex_y;

	//Calculating Rock/Grass Weight
	rock_grass_weight = max(min_rock_slope, rock_grass_weight);
	rock_grass_weight = min(max_grass_slope, rock_grass_weight);
	rock_grass_weight -= min_rock_slope;
	rock_grass_weight /= max_grass_slope - min_rock_slope;
				
	//Calculating Sand/RockGrass Weight
	sand_rockgrass_weight = max(min_rockgrass_height, sand_rockgrass_weight);
	sand_rockgrass_weight = min(max_sand_height, sand_rockgrass_weight);
	sand_rockgrass_weight -= min_rockgrass_height;
	sand_rockgrass_weight /= max_sand_height - min_rockgrass_height;

	//Mixing and Assigning Albedo
	//ALBEDO = mix(rock_albedo, grass_albedo, rock_grass_weight);
	vec3 rockgrass_albedo = mix(rock_albedo, grass_albedo, rock_grass_weight);
	ALBEDO = mix(sand_albedo, rockgrass_albedo, sand_rockgrass_weight);
}
