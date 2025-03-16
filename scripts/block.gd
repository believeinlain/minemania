extends CollisionObject3D

var index: Vector3i
var marked = false

signal mine_revealed(index: Vector3i)

func _enter_tree():
	var minefield = get_node("/root/Game/Minefield")
	connect("mine_revealed", minefield._on_mine_revealed)

func _input_event(camera: Camera3D, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not marked:
				mine_revealed.emit(index)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			mark()

func mark():
	var mesh = get_node("BlockMesh")
	if not marked:
		marked = true
		mesh.set_surface_override_material(0, preload("res://mat/block_marked.tres"))
	else:
		marked = false
		mesh.set_surface_override_material(0, null)
		
