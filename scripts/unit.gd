class_name Unit
extends Node2D

@onready var hurt_particles : GPUParticles2D = $HurtParticles
@onready var sprites : AnimatedSprite2D = $AnimatedSprite2D

var id : CharacterProfile
var health : int = 5
var starting_cell : Vector2i
var walking_distance : int = 3

func apply_profile(profile : CharacterProfile):
	id = profile
	sprites.sprite_frames = profile.sprite_frames

func respond_to_board(response : Callable):
	response.call(self)

func respond_to_board_spesifically(asking_for : CharacterProfile, response : Callable):
	if asking_for == id:
		response.call(self)

func respond_to_location(target : Vector2, response : Callable):
	if target.distance_to(position) <= .1:
		response.call(self)
