class_name Unit
extends Node2D

var id : int

func respond_to_board(response : Callable):
	response.call(self)

func respond_to_board_spesifically(asking_for : int, response : Callable):
	if asking_for == id:
		response.call(self)
