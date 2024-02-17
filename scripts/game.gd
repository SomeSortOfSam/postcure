extends Node

signal end_player_turn

func add_board(board : Board):
	add_child(board)
	end_player_turn.connect(board.process_turn.bind(true))

func _on_turn_button_pressed():
	end_player_turn.emit()
