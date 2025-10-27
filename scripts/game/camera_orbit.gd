extends Node3D

var mouse_down = false


func _input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_MIDDLE:
		mouse_down = event.is_pressed()

	if event is InputEventMouseMotion && mouse_down:
		var delta = event.screen_relative
		var delta_x = delta.x / get_viewport().size.x * TAU
		var delta_y = delta.y / get_viewport().size.y * TAU

		rotate(Vector3.UP, -delta_x)
		rotate(basis.x, -delta_y)
