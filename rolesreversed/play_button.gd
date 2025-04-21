extends Button

func _ready():
	# Use call_deferred to delay the connection until the scene tree is fully initialized
	call_deferred("_connect_to_game_manager")

func _connect_to_game_manager():
	var game_manager = get_tree().root.get_node("Game/GameManager")

	print(game_manager)
	if game_manager:
		pressed.connect(game_manager._on_play_button_pressed)
	else:
		print("GameManager node not found!")
