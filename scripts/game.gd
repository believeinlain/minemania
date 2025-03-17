extends Node3D


func _ready():
	var camera = get_node("CameraPivot/Camera3D")
	var settings = get_node("Settings")
	var minefield = get_node("Minefield")
	var block = preload("res://scenes/objects/block.tscn")

	var m_x = settings.field_size.x
	var m_y = settings.field_size.y
	var m_z = settings.field_size.z

	for x in m_x:
		for y in m_y:
			for z in m_z:
				var c_x = x - m_x / 2
				var c_y = y - m_y / 2
				var c_z = z - m_z / 2
				var instance = block.instantiate()
				instance.translate(Vector3(c_x, c_y, c_z))
				instance.index = Vector3i(x, y, z)
				minefield.add_child(instance)
				minefield.init_cell(instance.index, instance)
