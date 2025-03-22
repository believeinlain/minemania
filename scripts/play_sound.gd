extends AudioStreamPlayer3D


func _on_block_revealed(_index: Vector3i):
	stream = preload("res://audio/pop2.ogg")
	play()


func _ready():
	Global.block_revealed.connect(_on_block_revealed)
