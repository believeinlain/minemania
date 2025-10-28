class_name Game extends Node3D

enum GameState { PLAYING, WON, LOST }

@export var timer_label: Label
@export var result_label: Label

var state: GameState = GameState.PLAYING
var elapsed: float = 0.0


func is_playing():
	return state == GameState.PLAYING


func _physics_process(delta: float) -> void:
	if state == GameState.PLAYING:
		elapsed += delta
	timer_label.text = "%0.1f" % elapsed


func _on_minefield_win_game() -> void:
	state = GameState.WON
	result_label.text = "You Win!"
	result_label.visible = true


func _on_minefield_lose_game() -> void:
	state = GameState.LOST
	result_label.text = "You Lose"
	result_label.visible = true
