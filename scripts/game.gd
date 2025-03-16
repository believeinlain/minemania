extends Node3D

var minefield = Minefield.new()
@export var field_size = Vector3i(3, 3, 3)

func _ready():
	var block = preload("res://scenes/block.tscn")
	var camera = get_node("Camera/Camera3D")
	
	for x in field_size.x:
		for y in field_size.y:
			for z in field_size.z:
				var c_x = x - field_size.x / 2
				var c_y = y - field_size.y / 2
				var c_z = z - field_size.z / 2
				var instance = block.instantiate()
				instance.translate(Vector3(c_x, c_y, c_z))
				instance.index = Vector3i(x, y, z)
				instance.minefield = minefield
				add_child(instance)
				var cell = Cell.new()
				cell.contents = instance
				cell.index = Vector3i(x, y, z)
	
	minefield.initialize(field_size, field_size)
	
