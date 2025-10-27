extends Node

enum Safety { NONE, SAFE, CLEAR }

var size: Vector3i = Vector3i(3, 3, 3)
var mine_density: float = 0.2
var safety: Safety = Safety.SAFE
