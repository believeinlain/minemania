extends CollisionObject3D

var index: Vector3i
var marked = false

signal block_revealed(index: Vector3i)
signal block_marked(index: Vector3i, marked: bool)


func _enter_tree():
	var minefield = get_node("/root/Game/Minefield")
	if minefield == null:
		print_debug("Minefield not instantiated!")
		return

	connect("block_revealed", minefield._on_block_revealed)
	connect("block_marked", minefield._on_block_marked)


func _input_event(
	camera: Camera3D, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int
):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not marked:
				block_revealed.emit(index)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			mark()


func mark():
	var mark = get_node("Mark")
	if not marked:
		marked = true
		mark.visible = true
	else:
		marked = false
		mark.visible = false

	block_marked.emit(index, marked)
