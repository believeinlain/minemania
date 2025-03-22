class_name Minefield extends Node3D

enum MineSafety { NONE, SAFE, CLEAR }

var cells: Dictionary[Vector3i, Cell]
var initialized = false
var mouse_down = false
@export var indicator_scale = 1.0

@export var field_size: Vector3i = Vector3i(3, 3, 3)
@export var mine_density: float = 0.2
@export var safety: MineSafety = MineSafety.SAFE


func _input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_MIDDLE:
		mouse_down = event.is_pressed()

	if event is InputEventMouseMotion && mouse_down:
		var delta = event.screen_relative
		var delta_x = delta.x / get_viewport().size.x * TAU
		var delta_y = delta.y / get_viewport().size.y * TAU

		rotate(Vector3.UP, delta_x)
		rotate(Vector3.RIGHT, delta_y)


func _on_block_revealed(index: Vector3i):
	if not initialized:
		initialize(index)

	reveal(index)


func _on_block_marked(index: Vector3i, marked: bool):
	cells[index].marked = marked


func _on_indicator_mouseover(index: Vector3i, value: int, mouseover: bool):
	foreach_adjacent_facing(index, func(i): cells[i].instance_call("highlight", [value, mouseover]))


func _on_indicator_clicked(index: Vector3i):
	var all_true_marked = {"value": true}

	var check = func(idx):
		if !cells[idx].revealed and cells[idx].contains_mine:
			if !cells[idx].marked:
				all_true_marked["value"] = false

	foreach_adjacent_facing(index, check)
	if all_true_marked["value"]:
		disarm(index)


func _ready():
	Global.block_revealed.connect(_on_block_revealed)
	Global.block_marked.connect(_on_block_marked)
	Global.indicator_mouseover.connect(_on_indicator_mouseover)
	Global.indicator_clicked.connect(_on_indicator_clicked)

	spawn()


func spawn():
	var block = preload("res://objects/block.tscn")

	var m_x = field_size.x
	var m_y = field_size.y
	var m_z = field_size.z

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
			foreach_adjacent_facing(idx, func(idx): cells[idx].adjacent_mines -= 1)
			foreach_adjacent_facing(idx, update_indicator)
			cell.contains_mine = false
			reveal(idx)

	foreach_adjacent_facing(index, disarm_block)


func initialize(clicked: Vector3i):
	var num_blocks = field_size.x * field_size.y * field_size.z
	var num_mines: int = num_blocks * mine_density

	# Determine which cells cannot contain mines
	var safe_cells: Dictionary
	match safety:
		MineSafety.NONE:
			safe_cells = {}
		MineSafety.SAFE:
			safe_cells = {clicked: null}
		MineSafety.CLEAR:
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
	indicator.translate(cells[index].position)
	indicator.scale_object_local(Vector3.ONE * indicator_scale)
	indicator.value = adjacent_mines
	indicator.index = index
	add_child(indicator)

	return indicator
