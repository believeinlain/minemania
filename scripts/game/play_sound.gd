extends AudioStreamPlayer3D

@export var minefield: Minefield


func _on_block_revealed(_index: Vector3i):
	stream = preload("res://audio/pop2.ogg")
	play()


func _ready():
	minefield.block_revealed.connect(_on_block_revealed)
