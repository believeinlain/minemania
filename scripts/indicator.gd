class_name Indicator extends CollisionObject3D

var minefield: Minefield
var index: Vector3i
const SPEED = 1.8
@export var value = 1


static func get_mat(ivalue) -> Material:
	match ivalue:
		1:
			return preload("res://mat/indicator_1.tres")
		2:
			return preload("res://mat/indicator_2.tres")
		3:
			return preload("res://mat/indicator_3.tres")
		4:
			return preload("res://mat/indicator_4.tres")
		_:
			return preload("res://mat/indicator_1.tres")


func _exit_tree():
	minefield.indicator_mouseover.emit(index, value, false, Vector2.ZERO)


func _mouse_exit():
	minefield.indicator_mouseover.emit(index, value, false, Vector2.ZERO)


func _input_event(
	_camera: Camera3D,
	event: InputEvent,
	_event_position: Vector3,
	_normal: Vector3,
	_shape_idx: int
):
	if event is InputEventMouseMotion:
		minefield.indicator_mouseover.emit(index, value, true, event.position)
	elif event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			minefield.indicator_clicked.emit(index)


func _physics_process(delta):
	rotate_y(delta * SPEED)
