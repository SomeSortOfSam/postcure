class_name Board
extends TileMap

@export var unit_prefab : PackedScene
@export var poly_actions : Array[PolyAction]

var player_units : Dictionary
var enemy_units : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func process_turn(player_turn : bool):
	pass

func get_unit_groups(input_units : Dictionary) -> Array[Array]:
	var unvisted_units : Dictionary = input_units.duplicate()
	var output : Array[Array] = []
	while unvisted_units.size() > 0:
		output.append_array(find_groups_from_unit(unvisted_units.keys()[0],unvisted_units))
	return output

func find_groups_from_unit(position : Vector2i, unvisted_units : Dictionary) -> Array[Dictionary]:
	var connected_unit_queue : Dictionary = {}
	travel_connected(position, unvisted_units, func(unit_position, unit): connected_unit_queue[unit_position] = unit)
	var output : Array[Dictionary] = [connected_unit_queue.duplicate()]
	return output

func travel_connected(position : Vector2i, unvisted_units : Dictionary, on_visted : Callable):
	var unit : Unit = unvisted_units[position]
	unvisted_units.erase(position)
	for cell in get_surrounding_cells(position):
		if unvisted_units.has(cell):
			travel_connected(cell, unvisted_units, on_visted)
	on_visted.call(position, unit)

func get_neighboring_units(position : Vector2i, units : Dictionary) -> Array[Unit]:
	var output : Array[Unit] = []
	for cell in get_surrounding_cells(position):
		if units.has(cell):
			output.append(units[cell])
	return output
