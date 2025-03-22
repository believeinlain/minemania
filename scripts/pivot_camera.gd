extends Node3D

var mouse_down = false
@export var minefield: Node3D


func _enter_tree():
	look_at(Vector3.ZERO, Vector3.UP)


func _input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_MIDDLE:
		mouse_down = event.is_pressed()

	if event is InputEventMouseMotion && mouse_down:
		var delta = event.screen_relative
		var delta_x = delta.x / get_viewport().size.x * TAU
		var delta_y = delta.y / get_viewport().size.y * TAU
		var parent = get_parent_node_3d()
		var tilt = parent.basis.y.dot(Vector3.UP)

		minefield.rotate(parent.basis.y, delta_x)
		minefield.rotate(parent.basis.x, delta_y)

		tilt = parent.basis.y.dot(Vector3.UP)
		if tilt > 0.01:
			look_at(Vector3.ZERO, Vector3.UP)
		if tilt < -0.01:
			look_at(Vector3.ZERO, Vector3.DOWN)
