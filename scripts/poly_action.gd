## An abilty that activates on turn end based on unit positions. 
## To be stored in a list of avaible moves
## Bigger polycules will override smallers ones
class_name PolyAction
extends Resource

## List of connections between character ids in a tree structre
@export var root : CharacterProfile
@export var partners : Array[CharacterProfile]
@export var splash_art : Texture2D

## Returns what 
func get_cell_effects(units : Array[Unit], board : Board) -> Array[PolyEffect]:
	var direction := board.local_to_map(units[0].position) - board.local_to_map(units[-1].position)
	return [PolyEffect.new(board.local_to_map(units[0].position) + direction,1),PolyEffect.new(board.local_to_map(units[0].position) + direction + direction,2)]

class PolyEffect:
	var cell : Vector2i
	var damage : int
	
	func _init(new_cell : Vector2i, new_damage : int):
		self.cell = new_cell
		self.damage = new_damage
