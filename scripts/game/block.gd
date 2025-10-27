class_name Block extends CollisionObject3D

var minefield: Minefield
var index: Vector3i
var marked = false


func _input_event(
	_camera: Camera3D,
	event: InputEvent,
	_event_position: Vector3,
	_normal: Vector3,
	_shape_idx: int
):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not marked:
				minefield.block_revealed.emit(index)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			toggle_mark()


func toggle_mark():
	var mark = get_node("Mark")
	if not marked:
		marked = true
		mark.visible = true
	else:
		marked = false
		mark.visible = false

	minefield.block_marked.emit(index, marked)


func crack():
	var mesh: MeshInstance3D = get_node("BlockMesh")
	mesh.set_surface_override_material(0, preload("res://mat/block_cracked.tres"))


func highlight(value: int, mouseover: bool):
	var highlight_mesh: MeshInstance3D = get_node("Highlight")
	highlight_mesh.visible = mouseover
	highlight_mesh.set_surface_override_material(0, Indicator.get_mat(value))
