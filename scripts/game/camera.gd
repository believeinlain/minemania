extends Node3D

@export var camera_distance_factor: float = 1.5
@export var camera_distance_offset: float = 1.0
@export var camera_zoom_speed: float = 0.1


func _enter_tree():
	var field_size = Minefield.compute_world_size()
	var max_dim = max(field_size.x, field_size.y, field_size.z)
	var camera_dist = (max_dim / 2.0) * camera_distance_factor + camera_distance_offset
	var camera_pos = Vector3(0.0, camera_dist, camera_dist)
	look_at_from_position(camera_pos, Vector3.ZERO, Vector3.UP)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in"):
		var zoom_strength = event.get_action_strength("zoom_in")
		position = position.move_toward(Vector3.ZERO, zoom_strength * camera_zoom_speed)

	if event.is_action_pressed("zoom_out"):
		var zoom_strength = event.get_action_strength("zoom_out")
		position = position.move_toward(Vector3.ZERO, -zoom_strength * camera_zoom_speed)
