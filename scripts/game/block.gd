class_name Block extends CollisionObject3D

var minefield: Minefield
var index: Vector3i
var marked = false

@export var break_cascade_speed = 0.2


func _input_event(
	_camera: Camera3D,
	event: InputEvent,
	_event_position: Vector3,
	_normal: Vector3,
	_shape_idx: int
):
	if event is InputEventMouseButton && event.is_pressed() && minefield.game.is_playing():
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not marked:
				minefield.block_revealed.emit(index, false)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			toggle_mark()


func is_marked():
	return marked


func toggle_mark():
	if not marked:
		set_marked(true)
	else:
		set_marked(false)


func set_marked(mark_state: bool):
	var mark = get_node("Mark")

	marked = mark_state
	mark.visible = mark_state

	minefield.block_marked.emit(index, marked)


func crack():
	var mesh: MeshInstance3D = get_node("BlockMesh")
	mesh.set_surface_override_material(0, preload("res://mat/block_cracked.tres"))
	var break_cascade_timer = Timer.new()
	add_child(break_cascade_timer)
	break_cascade_timer.one_shot = true
	break_cascade_timer.timeout.connect(_on_break_cascade)
	break_cascade_timer.start(randf() * break_cascade_speed)


func highlight(value: int, mouseover: bool):
	var highlight_mesh: MeshInstance3D = get_node("Highlight")
	highlight_mesh.visible = mouseover
	highlight_mesh.set_surface_override_material(0, Indicator.get_mat(value))


func _on_break_cascade() -> void:
	minefield.block_revealed.emit(index, true)
