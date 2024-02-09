## An abilty that activates on turn end based on unit positions. 
## To be stored in a list of avaible moves
## Bigger polycules will override smallers ones
class_name PolyAction
extends Resource

## List of connections between character ids in a tree structre
@export var connecions : Array[Vector2i]
@export var splash_art : Texture2D
