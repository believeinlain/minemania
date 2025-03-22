class_name Cell extends Node3D

var instance: Node3D
var adjacent_mines = 0
var contains_mine = false
var revealed = false
var marked = false


static func create(instance: Node3D) -> Cell:
	var cell = Cell.new()
	cell.instance = instance
	cell.translate(instance.position)
	return cell


func instance_call(method: String, args = []):
	if instance != null:
		instance.callv(method, args)


func instance_delete():
	if instance != null:
		instance.queue_free()
		instance = null
