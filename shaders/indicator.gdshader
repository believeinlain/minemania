shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back, diffuse_burley;

uniform vec4 albedo : source_color;
uniform float emmissivity = 0.8;

uniform float roughness = 1.0;

uniform float specular = 0.5;
uniform float metallic = 0.58;

uniform float alpha = 0.75;

void fragment() {
	ALBEDO = albedo.rgb;
	EMISSION = albedo.rgb * emmissivity;

	METALLIC = metallic;
	SPECULAR = specular;

	ROUGHNESS = roughness;

	ALPHA = alpha;
}
