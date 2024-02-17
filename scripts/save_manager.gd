class_name SaveManager

const default_data : Dictionary = { "hub_level_path" : "res://scenes/test_hub.tscn",
									"level_path_array" : ["res://scenes/test_board.tscn"],
									"current_level_index" : 0, # If negitive, send to hub instead
									"display_name" : "Test Game",
									"achivement_flags" : 0 # This is entirely overkill
									}

const hub_prefab : PackedScene = preload("res://scenes/test_hub.tscn")
const board_prefab : PackedScene = preload("res://scenes/game.tscn")

static var save_location = 0

static func get_save_header(index : int) -> Dictionary:
	var data := get_save_data(index)
	return {"display_name" : data["display_name"], "achivement_flags" : data["achivement_flags"]}

static func achivement_flags_to_completion_percent(flags : int) -> float:
	return 0

static func load_save(index : int, tree : SceneTree):
	var data = get_save_data(index)
	
	await close_current_tree(tree)
	
	await switch_tree(tree,data)
	
	await open_new_tree(tree, data)

static func close_current_tree(tree : SceneTree):
	var pre_level_animatior : AnimationPlayer = tree.current_scene.get_node_or_null("Animations")
	if pre_level_animatior and pre_level_animatior.has_animation("Outro"):
		pre_level_animatior.play("Outro")
		await pre_level_animatior.animation_finished
	
	var level_transitioner := LevelTransition.get_node("AnimationPlayer") as AnimationPlayer
	level_transitioner.play("transition")
	await  level_transitioner.animation_finished

static func switch_tree(tree : SceneTree, data : Dictionary):
	if data["current_level_index"] < 0:
		switch_tree_to_hub_level(tree, data)
	else:
		switch_tree_to_board(tree, data)

static func switch_tree_to_hub_level(tree : SceneTree, data : Dictionary):
	var err = tree.change_scene_to_file(data["hub_level_path"])
	if not err == OK:
		print("Scene failed to load with error ", error_string(err))
	
	await tree.tree_changed

static func switch_tree_to_board(tree : SceneTree, data : Dictionary):
	var err = tree.change_scene_to_packed(board_prefab)
	if not err == OK:
		print("Scene failed to load with error ", error_string(err))
	
	var board_prefab : PackedScene = load(data["level_path_array"][data["current_level_index"]])
	
	await tree.tree_changed
	
	tree.current_scene.add_board(board_prefab.instantiate())

static func open_new_tree(tree : SceneTree, data : Dictionary):
	apply_saved_level_data(tree,data)
	
	var level_transitioner := LevelTransition.get_node("AnimationPlayer") as AnimationPlayer
	level_transitioner.play_backwards("transition")
	await level_transitioner.animation_finished
	
	var post_level_animatior : AnimationPlayer = tree.current_scene.get_node_or_null("Animations")
	if post_level_animatior and post_level_animatior.has_animation("Intro"):
		post_level_animatior.play("Intro")
		await post_level_animatior.animation_finished

static func apply_saved_level_data(tree : SceneTree, data : Dictionary):
	pass

static func get_save_data(index : int) -> Dictionary:
	var data := default_data
	if not FileAccess.file_exists("user://savegame_%s.save" % index):
		return data
	
	var save_game = FileAccess.open("user://savegame_%s.save" % index, FileAccess.READ)
	var json_string = save_game.get_as_text()
	
	# Creates the helper class to interact with JSON
	var json = JSON.new()
	
	# Check if there is any error while parsing the JSON string, skip in case of failure
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return data
	
	return json.get_data()

static func save(index : int, changes : Dictionary):
	var data = get_save_data(index)
	var save_game = FileAccess.open("user://savegame_%s.save" % index,FileAccess.WRITE)
	save_game.store_line(JSON.stringify(data,"\t"))
