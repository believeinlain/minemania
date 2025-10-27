extends Node3D

const SPEED = -3.0


func _physics_process(delta):
	rotate_y(SPEED * delta)
