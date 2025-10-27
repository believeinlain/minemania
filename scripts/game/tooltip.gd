extends Label


func _on_minefield_indicator_mouseover(_index: Vector3i, value: int, mouseover: bool, pos: Vector2):
	if mouseover:
		position = pos - pivot_offset
		text = "%s" % value
		visible = true
	else:
		visible = false
