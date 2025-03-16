class_name Settings extends Node

enum MineSafety { NONE, SAFE, CLEAR }

@export var field_size: Vector3i = Vector3i(3, 3, 3)
@export var mine_density: float = 0.2
@export var safety: MineSafety = MineSafety.SAFE
