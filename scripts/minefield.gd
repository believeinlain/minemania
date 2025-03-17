extends Node

var cells: Dictionary
var initialized = false


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


func _on_block_revealed(index: Vector3i):
	if not initialized:
		initialize(index)

	reveal(index)


func _on_block_marked(index: Vector3i, marked: bool):
	cells[index]["marked"] = marked
	print_debug("Marked: ", index, ", ", marked)


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

	if not cell["instance"] == null:
		cell["instance"].queue_free()
		cell["instance"] = null

	var cascade = func(index):
		# I think we don't want cascade?
		return
		if not cells[index]["revealed"]:
			cell["revealed"] = true
			var timer = Timer.new()
			timer.autostart = true
			timer.one_shot = true
			timer.wait_time = randf_range(0.2, 0.5)
			timer.timeout.connect(func(): _on_cascade_timeout(index))
			add_child(timer)

	if cell["contains_mine"]:
		var mine = preload("res://scenes/objects/mine.tscn")
		var instance = mine.instantiate()
		instance.translate(cell["position"])
		add_child(instance)
	else:
		var adjacent_mines = cell["adjacent_mines"]
		if adjacent_mines > 0:
			Indicator.spawn(self, adjacent_mines, cell["adjacent_cells"], cell["position"])
		else:
			foreach_adjacent_facing(index, cascade)


func initialize(clicked: Vector3i):
	var settings = get_node("../Settings")
	var size = settings.field_size
	var density = settings.mine_density

	var num_blocks = size.x * size.y * size.z
	var num_mines: int = num_blocks * density

	for index in cells.keys():
		foreach_adjacent_facing(index, func(adj_index): cells[index]["adjacent_cells"] += 1)
		print_debug(cells[index]["adjacent_cells"])

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
