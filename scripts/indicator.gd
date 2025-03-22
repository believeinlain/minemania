class_name Indicator extends CollisionObject3D

var speed = 0.03
@export var value = 1
var max = 0
var tooltip: Label


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
