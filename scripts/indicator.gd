class_name Indicator extends CollisionObject3D

var index: Vector3i
const SPEED = 1.8
@export var value = 1
var tooltip: Label


static func get_mat(value) -> Material:
	match value:
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


func _enter_tree():
	tooltip = get_node("/root/Game/Tooltip")


func _exit_tree():
	tooltip.visible = false


func _mouse_enter():
	tooltip.text = "%s" % value
	Global.indicator_mouseover.emit(index, value, true)


func _mouse_exit():
	tooltip.visible = false
	Global.indicator_mouseover.emit(index, value, false)


func _input_event(
	_camera: Camera3D,
	event: InputEvent,
	_event_position: Vector3,
	_normal: Vector3,
	_shape_idx: int
):
	if event is InputEventMouseMotion:
		tooltip.position = event.position - tooltip.pivot_offset
		tooltip.visible = true
	elif event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			Global.indicator_clicked.emit(index)


func _physics_process(delta):
	rotate_y(delta * SPEED)
