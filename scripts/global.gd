extends Node

signal block_revealed(index: Vector3i)
signal block_marked(index: Vector3i, marked: bool)

signal indicator_mouseover(index: Vector3i, value: int, mouseover: bool)
signal indicator_clicked(index: Vector3i)
