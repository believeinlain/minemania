extends Node

enum Safety { NONE, SAFE, CLEAR }

var size: Vector3i
var mine_density: float
var safety: Safety
var allow_disarming: bool
