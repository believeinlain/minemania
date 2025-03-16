extends Node

var cells: Dictionary
var initialized = false


func init_cell(index: Vector3i, instance: Node3D):
	cells[index] = {
		"instance": instance,
		"position": instance.position,
		"adjacent_mines": 0,
		"contains_mine": false,
		"revealed": false,
	}


func _on_block_revealed(index: Vector3i):
	if not initialized:
		initialize(index)

	reveal(index)


func _on_mine_marked(index: Vector3i):
	print_debug("Marked: ", index)


func reveal(index: Vector3i):
	var cell = cells[index]
	cell["revealed"] = true
	print_debug("Revealed: ", cell, " at ", index)

	cell["instance"].queue_free()
	cell["instance"] = null

	if cell["contains_mine"]:
		var mine = preload("res://scenes/mine.tscn")
		var instance = mine.instantiate()
		instance.translate(cell["position"])
		add_child(instance)

	# Reveal adjacent mines
	if cell["adjacent_mines"] == 0:
		foreach_adjacent(index, reveal_if_safe)


func reveal_if_safe(index: Vector3i):
	if !cells[index]["revealed"] and !cells[index]["contains_mine"]:
		reveal(index)


func initialize(clicked: Vector3i):
	var settings = get_node("../Settings")
	var size = settings.field_size
	var density = settings.mine_density

	var num_blocks = size.x * size.y * size.z
	var num_mines: int = num_blocks * density

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
			foreach_adjacent(clicked, func(adj_index): safe_cells[adj_index] = null)

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
		foreach_adjacent(mine_index, func(adj_index): cells[adj_index]["adjacent_mines"] += 1)

		print_debug("Placed mine at ", mine_index, ", ", mines_to_place, " remaining")

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
