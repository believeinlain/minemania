class_name Minefield extends Node3D

var cells: Dictionary[Vector3i, Cell]
var initialized = false

@export var game: Game
@export var indicator_scale = 1.0
@export var block: PackedScene

signal block_revealed(index: Vector3i)
signal block_marked(index: Vector3i, marked: bool)

signal indicator_mouseover(index: Vector3i, value: int, mouseover: bool, pos: Vector2)
signal indicator_clicked(index: Vector3i)

signal win_game
signal lose_game


static func compute_world_size() -> Vector3:
	var block_scale = 1.0
	return Vector3(Field.size) * block_scale


func _on_block_revealed(index: Vector3i):
	if not initialized:
		initialize(index)

	reveal(index)

	if game.is_playing() && is_game_won():
		win_game.emit()


func _on_block_marked(index: Vector3i, marked: bool):
	cells[index].instance.marked = marked


func _on_indicator_mouseover(index: Vector3i, value: int, mouseover: bool, _pos: Vector2):
	foreach_adjacent_facing(index, func(i): cells[i].instance_call("highlight", [value, mouseover]))


func _on_indicator_clicked(index: Vector3i):
	if !Field.allow_disarming || !game.is_playing():
		return

	var all_true_marked = {"value": true}

	var check = func(idx):
		var cell = cells[idx]
		if (
			(cell.contains_mine and cell.revealed)
			or (!cell.revealed and !cell.contains_mine)
			or (!cell.revealed and cell.contains_mine and !cell.instance_call("is_marked"))
		):
			all_true_marked["value"] = false

	foreach_adjacent_facing(index, check)
	if all_true_marked["value"]:
		disarm(index)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("game_exit"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _ready():
	var m_x = Field.size.x
	var m_y = Field.size.y
	var m_z = Field.size.z

	for x in m_x:
		for y in m_y:
			for z in m_z:
				var c = Vector3(x, y, z) - Vector3(Field.size) / 2.0
				var instance = block.instantiate()
				instance.minefield = self
				instance.translate(c + Vector3.ONE / 2.0)
				instance.index = Vector3i(x, y, z)
				add_child(instance)
				cells[instance.index] = Cell.create(instance)


func reveal(index: Vector3i):
	var cell := cells[index]
	if cell.revealed:
		return

	cell.revealed = true
	cell.instance_delete()

	if cell.contains_mine:
		var mine = preload("res://objects/mine.tscn")
		var instance = mine.instantiate()
		instance.translate(cell.position)
		add_child(instance)
		if game.is_playing():
			lose_game.emit()
	else:
		if cell.adjacent_mines > 0:
			cell.instance = spawn_indicator(index)
		else:
			foreach_adjacent_facing(index, func(i): cells[i].instance_call("crack"))


func disarm(index: Vector3i):
	var update_indicator = func(idx):
		var cell := cells[idx]
		if cell.instance is Indicator:
			cell.instance_delete()
			if cell.adjacent_mines > 0:
				cell.instance = spawn_indicator(idx)

	var disarm_block = func(idx):
		var cell := cells[idx]
		if cell.contains_mine:
			cell.instance_delete()
			foreach_adjacent_facing(idx, func(adj_idx): cells[adj_idx].adjacent_mines -= 1)
			foreach_adjacent_facing(idx, update_indicator)
			cell.contains_mine = false
			reveal(idx)
			var disarmed_mine = preload("res://objects/mine_disarmed.tscn").instantiate()
			disarmed_mine.translate(cell.position)
			add_child(disarmed_mine)

	foreach_adjacent_facing(index, disarm_block)


func initialize(clicked: Vector3i):
	var num_blocks = Field.size.x * Field.size.y * Field.size.z
	var num_mines: int = num_blocks * Field.mine_density

	# Determine which cells cannot contain mines
	var safe_cells: Dictionary
	match Field.safety:
		Field.Safety.NONE:
			safe_cells = {}
		Field.Safety.SAFE:
			safe_cells = {clicked: null}
		Field.Safety.CLEAR:
			safe_cells = {clicked: null}
			foreach_adjacent_facing(clicked, func(adj_idx): safe_cells[adj_idx] = null)

	# Every cell that is not guaranteed to be safe might contain a mine
	var unsafe_cells: Array = cells.keys().filter(func(index): return !safe_cells.has(index))
	#seed(314)
	unsafe_cells.shuffle()

	# Place mines
	var mines_to_place = num_mines
	while mines_to_place > 0:
		var mine_index = unsafe_cells.pop_front()
		if mine_index == null:
			break

		cells[mine_index].contains_mine = true

		# Increment the number of adjacent mines in each cell next to a new mine
		foreach_adjacent_facing(mine_index, func(adj_index): cells[adj_index].adjacent_mines += 1)

		mines_to_place -= 1

	initialized = true


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


func spawn_indicator(index) -> Node:
	var adjacent_mines = cells[index].adjacent_mines
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

	var indicator := res.instantiate()
	indicator.minefield = self
	indicator.translate(cells[index].position)
	indicator.scale_object_local(Vector3.ONE * indicator_scale)
	indicator.value = adjacent_mines
	indicator.index = index
	add_child(indicator)

	return indicator


func is_game_won():
	var m_x = Field.size.x
	var m_y = Field.size.y
	var m_z = Field.size.z

	for x in m_x:
		for y in m_y:
			for z in m_z:
				var index = Vector3i(x, y, z)
				var cell = cells[index]

				# any empty blocks must be broken to win
				if !cell.contains_mine && !cell.revealed:
					return false

	# otherwise we win!
	return true


func mark_remaining_mines():
	var m_x = Field.size.x
	var m_y = Field.size.y
	var m_z = Field.size.z

	for x in m_x:
		for y in m_y:
			for z in m_z:
				var index = Vector3i(x, y, z)
				var cell = cells[index]

				if cell.contains_mine:
					cell.instance_call("set_marked", [true])


func reveal_remaining_mines():
	var m_x = Field.size.x
	var m_y = Field.size.y
	var m_z = Field.size.z

	for x in m_x:
		for y in m_y:
			for z in m_z:
				var index = Vector3i(x, y, z)
				var cell = cells[index]

				if cell.contains_mine && cell.instance_call("is_marked"):
					pass
				else:
					reveal(index)


func _on_win_game() -> void:
	mark_remaining_mines()


func _on_lose_game() -> void:
	reveal_remaining_mines()
