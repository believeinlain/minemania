extends Node3D

var speed = -0.05

func _physics_process(delta):
	rotate_y(speed)
