extends AudioStreamPlayer3D


func _on_minefield_block_revealed(_index: Vector3i, _cascade: bool) -> void:
	stream = preload("res://audio/pop2.ogg")
	#if !cascade:
	play()
