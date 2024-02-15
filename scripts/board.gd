class_name Board
extends TileMap

const PLAYER_ATLAS_COORD := [Vector2i(1,0)]
const UNIT_ATLAS_COORD := [Vector2i(1,0),Vector2i(2,0)]

@export var unit_prefab : PackedScene
@export var poly_actions : Array[PolyAction]
@export var character_profiles : Array[CharacterProfile]

var currently_selected_unit : Unit

signal requesting_player_response(response : Callable)
signal requesting_spesific_player_response(id : int, response : Callable)
signal requesting_located_player_response(target : Vector2, response : Callable)
signal requesting_enemey_response(response : Callable)
signal requesting_spesific_enemey_response(id : int, response : Callable)
signal requesting_located_enemey_response(target : Vector2, response : Callable)

# Called when the node enters the scene tree for the first time.
func _ready():
	populate_units()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		on_left_mouse_pressed(event)

func on_left_mouse_pressed(event : InputEventMouseButton):
	var target_cell := local_to_map(event.global_position) - Vector2i(17,14) # Magic vector? Where did this come from?
	var cell_pos := map_to_local(target_cell)
	requesting_located_player_response.emit(cell_pos, func(unit : Unit): 
		currently_selected_unit = unit
		if currently_selected_unit:
			clear_layer(2)
			clear_layer(3)
			highlight_moveable_cells(currently_selected_unit.starting_cell, currently_selected_unit.walking_distance)
	)
	if not currently_selected_unit or not try_move(cell_pos):
		deselect_unit()

func deselect_unit():
	currently_selected_unit = null
	clear_layer(2)
	var actions := get_actions(true)
	for action : PolyAction in actions.keys():
		for poly_effect in action.get_cell_effects(actions[action],self):
			set_cell(3,poly_effect.cell,1,Vector2i.ZERO)

func highlight_moveable_cells(cell : Vector2i, distance : int):
	if distance <= 0:
		return
	for neighbor : Vector2i in get_surrounding_cells(cell):
		highlight_moveable_cells(neighbor,distance - 1)
	if get_cell_source_id(0,cell) != -1:
		set_cell(2,cell, 1, Vector2i.ZERO)

func try_move(target : Vector2) -> bool:
	var current_cell : Vector2i = currently_selected_unit.starting_cell
	var target_cell : Vector2i = local_to_map(target)
	var diffrence : Vector2i = abs(current_cell - target_cell)
	if diffrence.length() < currently_selected_unit.walking_distance:
		currently_selected_unit.position = map_to_local(target_cell)
		return true
	return false

func populate_units():
	for cell : Vector2i in get_used_cells(1):
		var unit_atlas_coord := get_cell_atlas_coords(1,cell)
		if not UNIT_ATLAS_COORD.has(unit_atlas_coord):
			unit_atlas_coord = PLAYER_ATLAS_COORD.pick_random()
		var unit : Unit = unit_prefab.instantiate()
		add_child(unit)
		unit.apply_profile(character_profiles[UNIT_ATLAS_COORD.find(unit_atlas_coord)])
		unit.position = map_to_local(cell)
		unit.starting_cell = cell
		(requesting_located_player_response if PLAYER_ATLAS_COORD.has(unit_atlas_coord) else requesting_located_enemey_response).connect(unit.respond_to_location)
		(requesting_player_response if PLAYER_ATLAS_COORD.has(unit_atlas_coord) else requesting_enemey_response).connect(unit.respond_to_board)
		(requesting_spesific_player_response if PLAYER_ATLAS_COORD.has(unit_atlas_coord) else requesting_spesific_enemey_response).connect(unit.respond_to_board_spesifically)
	set_layer_modulate(1,Color(Color.WHITE,0))

func process_turn(player_turn : bool):
	process_movement(player_turn)
	var action_set : Dictionary = get_actions(player_turn)
	for action : PolyAction in action_set.keys():
		var effects := action.get_cell_effects(action_set[action],self)
		for effect in effects:
			(requesting_located_enemey_response if player_turn else requesting_located_player_response).emit(map_to_local(effect.cell), func(unit : Unit):
				unit.health -= effect.damage
			)
	if player_turn:
		process_turn(false)

func process_movement(player_turn : bool):
	clear_layer(2)
	if player_turn:
		requesting_player_response.emit(func(unit): unit.starting_cell = local_to_map(unit.position))
	else:
		move_enemies()

func move_enemies():
	pass

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
	if action.partners.size() <= 0 or not units.has(action.root):
		return []
	for root : Unit in units[action.root]:
		var output : Array[Unit] = []
		for partner : CharacterProfile in action.partners:
			var adjacent = get_adjacent_unit(root,units, partner)
			if adjacent:
				output.append(adjacent)
			else:
				break
		if output.size() == action.partners.size():
			output.append(root)
			return output
	return []

func get_adjacent_unit(unit : Unit, units : Dictionary, id : CharacterProfile) -> Unit:
	if not units.has(id):
		return null
		
	var unit_cell := local_to_map(unit.position)
	var valid_cells := get_surrounding_cells(unit_cell)
	for canidate in units[id]:
		if valid_cells.has(local_to_map(canidate.position)):
			return canidate
	return null
