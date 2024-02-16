extends Control

@onready var main_menu : Control = %MainMenu
@onready var saves : Control = %Saves
#@onready var credits : Control = %Credits

@export var save_loader : PackedScene

var overwrite : bool = false

func _on_new_game_pressed():
	main_menu.hide()
	saves.show()
	overwrite = true

func _on_load_game_pressed():
	main_menu.hide()
	saves.show()
	overwrite = false

func _on_quit_game_pressed():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()

func _on_save_pressed(index : int):
	if overwrite:
		SaveManager.load_save(-1,get_tree())
	else:
		SaveManager.load_save(index,get_tree())
	SaveManager.save_location = index


#func _on_credits_control_mouse_entered():
#	main_menu.hide()
#	saves.hide()
#	credits.show()


#func _on_credits_control_mouse_exited():
#	main_menu.show()
#	saves.hide()
#	credits.hide()
