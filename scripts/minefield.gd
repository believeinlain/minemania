class_name Minefield extends Node3D

var cells: Dictionary
var initialized = false


func _on_block_revealed(index: Vector3i):
	if not initialized:
		initialize(index)

	reveal(index)


func _on_block_marked(index: Vector3i, marked: bool):
	cells[index]["marked"] = marked


func _ready():
	Global.block_revealed.connect(_on_block_revealed)
	Global.block_marked.connect(_on_block_marked)

	spawn()


func spawn():
	var camera = get_node("../CameraPivot/Camera3D")
	var settings = get_node("../Settings")
	var block = preload("res://objects/block.tscn")

	var m_x = settings.field_size.x
	var m_y = settings.field_size.y
	var m_z = settings.field_size.z

	for x in m_x:
		for y in m_y:
			for z in m_z:
				var c_x = x - m_x / 2
				var c_y = y - m_y / 2
				var c_z = z - m_z / 2
				var instance = block.instantiate()
				instance.translate(Vector3(c_x, c_y, c_z))
				instance.index = Vector3i(x, y, z)
				add_child(instance)
				init_cell(instance.index, instance)


func init_cell(index: Vector3i, instance: Node3D):
	cells[index] = {
		"instance": instance,
		"position": instance.position,
		"adjacent_mines": 0,
		"adjacent_cells": 0,
		"contains_mine": false,
		"revealed": false,
		"marked": false,
	}


func instance_call(index: Vector3i, name: String):
	var instance: Object = cells[index]["instance"]
	if instance != null:
		instance.call(name)


func _on_cascade_timeout(index: Vector3i):
	reveal(index)


func reveal(index: Vector3i):
	var reveal_sound = preload("res://audio/pop2.ogg")
	var cell = cells[index]
	if cell["revealed"]:
		return

	cell["revealed"] = true
	#print_debug("Revealed: ", cell, " at ", index)
	var sound_player = AudioStreamPlayer3D.new()
	add_child(sound_player)
	sound_player.stream = reveal_sound
	sound_player.position = cell["position"]
	sound_player.play()
	# TODO: Remove stream player after done playing!

	instance_call(index, "delete")
	cell["instance"] = null

	if cell["contains_mine"]:
		var mine = preload("res://objects/mine.tscn")
		var instance = mine.instantiate()
		instance.translate(cell["position"])
		add_child(instance)
	else:
		var adjacent_mines = cell["adjacent_mines"]
		if adjacent_mines > 0:
			spawn_indicator(self, adjacent_mines, cell["adjacent_cells"], cell["position"])
		else:
			foreach_adjacent_facing(index, func(index): instance_call(index, "crack"))


func initialize(clicked: Vector3i):
	var settings = get_node("../Settings")
	var size = settings.field_size
	var density = settings.mine_density

	var num_blocks = size.x * size.y * size.z
	var num_mines: int = num_blocks * density

	for index in cells.keys():
		foreach_adjacent_facing(index, func(adj_index): cells[index]["adjacent_cells"] += 1)
		#print_debug(cells[index]["adjacent_cells"])

	print_debug("Density=", density, " num_mines=", num_mines, "/", num_blocks)

	# Determine which cells cannot contain mines
	var safe_cells: Dictionary
	match settings.safety:
		Settings.MineSafety.NONE:
			safe_cells = {}
		Settings.MineSafety.SAFE:
			safe_cells = {clicked: null}
		Settings.MineSafety.CLEAR:
			safe_cells = {clicked: null}
			foreach_adjacent_facing(clicked, func(adj_index): safe_cells[adj_index] = null)

	print_debug("Safe cells: ", safe_cells.keys())

	# Every cell that is not guaranteed to be safe might contain a mine
	var unsafe_cells: Array = cells.keys().filter(func(index): return !safe_cells.has(index))
	unsafe_cells.shuffle()

	# Place mines
	var mines_to_place = num_mines
	while mines_to_place > 0:
		var mine_index = unsafe_cells.pop_front()
		if mine_index == null:
			break

		cells[mine_index]["contains_mine"] = true

		# Increment the number of adjacent mines in each cell next to a new mine
		foreach_adjacent_facing(
			mine_index, func(adj_index): cells[adj_index]["adjacent_mines"] += 1
		)

		#print_debug("Placed mine at ", mine_index, ", ", mines_to_place, " remaining")

		mines_to_place -= 1

	initialized = true


func foreach_adjacent(index: Vector3i, f: Callable):
	for x_off in [-1, 0, 1]:
		for y_off in [-1, 0, 1]:
			for z_off in [-1, 0, 1]:
				# The block at index is not adjacent to itself
				if x_off == 0 and y_off == 0 and z_off == 0:
					continue

				# Get a block adjacent to index
				var adj_index = Vector3i(index.x + x_off, index.y + y_off, index.z + z_off)

				if not cells.has(adj_index):
					continue

				f.call(adj_index)


func foreach_adjacent_facing(index: Vector3i, f: Callable):
	var adjacent_facing = [
		Vector3i(1, 0, 0),
		Vector3i(0, 1, 0),
		Vector3i(0, 0, 1),
		Vector3i(-1, 0, 0),
		Vector3i(0, -1, 0),
		Vector3i(0, 0, -1),
	]
	for adj in adjacent_facing:
		var adj_index = index + adj
		if not cells.has(adj_index):
			continue

		f.call(adj_index)


static func spawn_indicator(parent: Node, adjacent_mines, adjacent_cells, position: Vector3):
	var res: PackedScene
	match adjacent_mines:
		1:
			res = preload("res://objects/indicator_1.tscn")
		2:
			res = preload("res://objects/indicator_2.tscn")
		3:
			res = preload("res://objects/indicator_3.tscn")
		4:
			res = preload("res://objects/indicator_4.tscn")
		5:
			res = preload("res://objects/indicator_5.tscn")
		6:
			res = preload("res://objects/indicator_6.tscn")

	var indicator: Indicator = res.instantiate()
	indicator.translate(position)
	indicator.value = adjacent_mines
	parent.add_child(indicator)
