extends Node3D

@export var camera_distance_factor: float = 1.5
@export var camera_distance_offset: float = 1.0


func _enter_tree():
	var field_size = Minefield.compute_world_size()
	var max_dim = max(field_size.x, field_size.y, field_size.z)
	var camera_dist = (max_dim / 2.0) * camera_distance_factor + camera_distance_offset
	var camera_pos = Vector3(0.0, camera_dist, camera_dist)
	look_at_from_position(camera_pos, Vector3.ZERO, Vector3.UP)
