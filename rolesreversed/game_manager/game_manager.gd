extends Control

@onready var agent_scene = preload("res://ai_agent/master_agent.tscn")

func _ready():
	print("Game Manager scene is loaded and ready!")

func _on_play_button_pressed():
	# Spawn two agents at different positions
	# var agent1 = agent_scene.instantiate()
	# var agent2 = agent_scene.instantiate()
	
	# # Set their positions (you can adjust these coordinates as needed)
	# agent1.position = Vector2(100, 100)
	# agent2.position = Vector2(300, 100)
	
	# # Add them to the scene
	# add_child(agent1)
	# add_child(agent2)
	print("Spawned two agents!")
