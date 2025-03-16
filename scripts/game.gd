extends Node3D

func _ready():
	var block = preload("res://scenes/block.tscn")
	var instance = block.instantiate()
	add_child(instance)
