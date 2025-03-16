shader_type spatial;

render_mode cull_front, depth_draw_always, diffuse_burley;

uniform vec4 outline_color : source_color;
uniform float outline_emmissivity : hint_range(0.0, 1.0) = 0.5;
uniform float outline_width : hint_range(0.0, 50.0);
uniform float outline_alpha : hint_range(0.0, 1.0) = 0.7;

void vertex() {
	vec4 clip_position =
			PROJECTION_MATRIX *
			(MODELVIEW_MATRIX * vec4(VERTEX, 1.0));
	vec3 clip_normal =
			mat3(PROJECTION_MATRIX) *
			(mat3(MODELVIEW_MATRIX) * NORMAL);
	clip_position.xy +=
			normalize(clip_normal.xy) /
			VIEWPORT_SIZE *
			clip_position.w *
			outline_width;
	POSITION = clip_position;
}

void fragment() {
	ALBEDO = outline_color.rgb;
	ALPHA = outline_alpha;
	EMISSION = outline_color.rgb * outline_emmissivity;
}