class_name Unit
extends Node2D

var id : int
var starting_cell : Vector2i
var walking_distance : int = 3

func apply_profile(_profile : CharacterProfile):
	pass

func respond_to_board(response : Callable):
	response.call(self)

func respond_to_board_spesifically(asking_for : int, response : Callable):
	if asking_for == id:
		response.call(self)

func respond_to_location(target : Vector2, response : Callable):
	if target.distance_to(position) <= .1:
		response.call(self)
