class_name Unit
extends Node2D

@onready var hurt_particles : GPUParticles2D = $HurtParticles
@onready var sprites : AnimatedSprite2D = $AnimatedSprite2D

var id : CharacterProfile
var health : int = 5:
	set(new_health):
		if new_health <= 0:
			dead.emit()
		if hurt_particles and health < new_health:
			hurt_particles.emitting = true
		health = new_health
var starting_cell : Vector2i
var walking_distance : int = 3

signal dead

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
