class_name SaveManager

const LEVEL_0 : String = "res://scenes/game.tscn"

static var save_location = 0

static func load_save(index : int, tree : SceneTree):
	var data : Dictionary = {"Level" : LEVEL_0, "Checkpoint" : 0}
	if FileAccess.file_exists("user://savegame_%s.save" % index):
		var save_game = FileAccess.open("user://savegame_%s.save" % index, FileAccess.READ)
		var json_string = save_game.get_line()

		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			return
		
		data = json.get_data()
	
	var pre_level_animatior : AnimationPlayer = tree.current_scene.get_node_or_null("Animations")
	if pre_level_animatior and pre_level_animatior.has_animation("Outro"):
		pre_level_animatior.play("Outro")
		await pre_level_animatior.animation_finished
	
	var level_transitioner := LevelTransition.get_node("AnimationPlayer") as AnimationPlayer
	level_transitioner.play("transition")
	await  level_transitioner.animation_finished
	
	var err = tree.change_scene_to_file(data["Level"])
	if not err == OK:
		print("Scene failed to load with error ", error_string(err))
		return
	
	await tree.tree_changed
	
	var checkpoint_parent = tree.current_scene.get_node_or_null("CatCheckpoints")
	if checkpoint_parent:
		var checkpoint = checkpoint_parent.get_child(data["Checkpoint"])
		var player_character = tree.current_scene.get_node_or_null("PlayerCat")
		player_character.position = checkpoint.to_global(checkpoint.respawn_point)
		player_character.checkpoint = checkpoint
	
	level_transitioner.play_backwards("transition")
	await level_transitioner.animation_finished
	
	var post_level_animatior : AnimationPlayer = tree.current_scene.get_node_or_null("Animations")
	if post_level_animatior and post_level_animatior.has_animation("Intro"):
		post_level_animatior.play("Intro")
		await post_level_animatior.animation_finished

static func save(index : int, level : StringName, checkpoint : int):
	var save_game = FileAccess.open("user://savegame_%s.save" % index,FileAccess.WRITE)
	var data = {"Level" : level, "Checkpoint" : checkpoint}
	save_game.store_line(JSON.stringify(data))
