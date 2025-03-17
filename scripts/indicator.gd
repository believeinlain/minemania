class_name Indicator extends CollisionObject3D

var speed = 0.03
@export var value = 1
var max = 0
var tooltip: Label


static func spawn(parent: Node, adjacent_mines, adjacent_cells, position: Vector3):
	var res: PackedScene
	match adjacent_mines:
		1:
			res = preload("res://scenes/objects/indicator_1.tscn")
		2:
			res = preload("res://scenes/objects/indicator_2.tscn")
		3:
			res = preload("res://scenes/objects/indicator_3.tscn")
		4:
			res = preload("res://scenes/objects/indicator_4.tscn")
		5:
			res = preload("res://scenes/objects/indicator_5.tscn")

	var indicator: Indicator = res.instantiate()
	indicator.translate(position)
	indicator.value = adjacent_mines
	indicator.max = adjacent_cells
	parent.add_child(indicator)


func _enter_tree():
	tooltip = get_node("/root/Game/Tooltip")


func _mouse_enter():
	tooltip.text = "%s" % value
	print_debug("mousover ", value)


func _mouse_exit():
	tooltip.visible = false


func _input_event(
	camera: Camera3D, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int
):
	if event is InputEventMouseMotion:
		tooltip.position = event.position - tooltip.pivot_offset
		tooltip.visible = true


func _physics_process(delta):
	rotate_y(speed)
