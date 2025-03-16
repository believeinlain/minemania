extends Node3D

var speed = 0.03

func _physics_process(delta):
	rotate_y(speed)
