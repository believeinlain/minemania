extends Control

@export var density_control: Range
@export var size_control: Range
@export var safety_option: OptionButton

@export var preset_small_button: Button
@export var preset_medium_button: Button
@export var preset_large_button: Button

const PRESET_SMALL = {"size": 3, "density": 0.2, "safety": Field.Safety.SAFE}
const PRESET_MEDIUM = {"size": 5, "density": 0.1, "safety": Field.Safety.SAFE}
const PRESET_LARGE = {"size": 9, "density": 0.1, "safety": Field.Safety.SAFE}


func _ready() -> void:
	safety_option.set_item_tooltip(
		Field.Safety.NONE, "The first block broken might contain a mine."
	)
	safety_option.set_item_tooltip(
		Field.Safety.SAFE, "The first block broken will not contain a mine."
	)
	safety_option.set_item_tooltip(
		Field.Safety.CLEAR, "Blocks adjacent to the first block broken will not contain a mine."
	)


func apply_preset(preset: Dictionary):
	size_control.value = preset.size
	density_control.value = preset.density
	safety_option.select(preset.safety)


func _on_preset_small_pressed() -> void:
	apply_preset(PRESET_SMALL)


func _on_preset_medium_pressed() -> void:
	apply_preset(PRESET_MEDIUM)


func _on_preset_large_pressed() -> void:
	apply_preset(PRESET_LARGE)


func _on_size_control_value_changed(value: float) -> void:
	var s = int(value)
	Field.size = Vector3i(s, s, s)


func _on_density_control_value_changed(value: float) -> void:
	Field.mine_density = value


func _on_safety_option_item_selected(index: int) -> void:
	Field.safety = index as Field.Safety


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit(0)
