class_name Board
extends TileMap

const CHARACTER_IS_PLAYER := [true,true,false]

@export var unit_prefab : PackedScene
@export var poly_actions : Array[PolyAction]
@export var character_profiles : Array[CharacterProfile]

signal requesting_player_response(response : Callable)
signal requesting_spesific_player_response(id : int, response : Callable)
signal requesting_enemey_response(response : Callable)
signal requesting_spesific_enemey_response(id : int, response : Callable)

# Called when the node enters the scene tree for the first time.
func _ready():
	populate_units()

func populate_units():
	for cell : Vector2i in get_used_cells(1):
		var id = get_cell_source_id(1,cell)
		var unit : Unit = unit_prefab.instantiate()
		add_child(unit)
		unit.position = map_to_local(cell)
		unit.id = id
		(requesting_player_response if CHARACTER_IS_PLAYER[id] else requesting_enemey_response).connect(unit.respond_to_board)
		(requesting_spesific_player_response if CHARACTER_IS_PLAYER[id] else requesting_spesific_enemey_response).connect(unit.respond_to_board_spesifically)
	set_layer_modulate(1,Color(Color.WHITE,0))

func process_turn(player_turn : bool):
	var action_set : Dictionary = get_actions(player_turn)


func get_actions(player_turn : bool) -> Dictionary: # { PolyAction : Array[Unit] }
	var output : Dictionary = {}
	var units : Dictionary = {} # { int : Array[Unit] }
	(requesting_player_response if player_turn else requesting_enemey_response).emit(
		func(unit : Unit): 
			if not units.has(unit.id):
				units[unit.id] = []
			(units[unit.id] as Array[Unit]).append(unit)
	)
	for action : PolyAction in poly_actions:
		var group : Array[Unit] = get_units_for_action(action,units)
		if group.size() > 0:
			output[action] = group
	return output

## returns a set of units that are valid for an action, or an empty array if no group exists
func get_units_for_action(action : PolyAction, units : Dictionary) -> Array[Unit]:
	if action.connecions.size() <= 0 or not units.has(action.connecions[0].x):
		return []
	for root : Unit in units[action.connecions[0].x]:
		var output : Array[Unit] = []
		for connection : Vector2i in action.connecions:
			var adjacent = get_adjacent_unit(root,units, connection.y)
			if adjacent:
				output.append(adjacent)
	return []

func get_adjacent_unit(unit : Unit, units : Dictionary, id : int) -> Unit:
	if not units.has(id):
		return null
		
	var unit_cell := local_to_map(unit.position)
	var valid_cells := get_surrounding_cells(unit_cell)
	for canidate in units[id]:
		if valid_cells.has(local_to_map(unit.position)):
			return canidate
	return null

func get_neighboring_units(position : Vector2i, units : Dictionary) -> Array[Unit]:
	var output : Array[Unit] = []
	for cell in get_surrounding_cells(position):
		if units.has(cell):
			output.append(units[cell])
	return output
