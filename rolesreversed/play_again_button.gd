extends Button

func _ready():
	# Use call_deferred to delay the connection until the scene tree is fully initialized
	#call_deferred("_connect_to_game_manager")
	pressed.connect(_on_button_pressed)

func _connect_to_game_manager():
	var game_manager = get_tree().root.get_node("Game/GameManager")

	print(game_manager)
	if game_manager:
		pressed.connect(game_manager._on_play_button_pressed)
	else:
		print("GameManager node not found!")

func _on_button_pressed():
	# Disable the button
	#self.disabled = true
	
	print("Restarting the game...")
	get_tree().reload_current_scene()
	
	#get_tree().change_scene("res://map/map.tscn")
	# # Hide the parent menu
	# var parent_menu = get_parent()
	# if parent_menu:
	#     parent_menu.visible = false
	
	# # Clear everything under the GameManager
	# var game_manager = get_tree().root.get_node("Game/GameManager")
	# if game_manager:
	#     for child in game_manager.get_children():
	#         game_manager.remove_child(child)
	#         child.queue_free()

	# # Reload the current scene to its initial state
	# if game_manager:
	#     get_tree().reload_current_scene()

	
