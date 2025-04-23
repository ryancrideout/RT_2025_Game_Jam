extends Control

@onready var agent_scene = preload("res://ai_agent/master_agent.tscn")
@onready var grim_reaper_scene = preload("res://grim_reaper/GrimReaper.tscn")

func _ready():
	print("Game Manager scene is loaded and ready!")

func _on_play_button_pressed():

	spawn_grim_reaper(Vector2(5000, 5000))

	# Spawn two agents with different positions and names
	spawn_agent(Vector2(3500, 5000),
				"res://ai_agent/skeleton_castle.tscn",
				"/root/Game/GameManager/GrimReaper/UILayer/AgentUI/VBoxContainer/ResourcesContainer/HBoxContainer/UndeadVBoxContainer",
				"SkeletonAgent")
	spawn_agent(Vector2(6500, 5000),
				"res://ai_agent/human_castle.tscn",
				"/root/Game/GameManager/GrimReaper/UILayer/AgentUI/VBoxContainer/ResourcesContainer/HBoxContainer/HumanVBoxContainer",
				"HumanAgent")

# Spawn an agent at the specified position with a given name
func spawn_agent(spawn_position: Vector2, main_building_scene_path: String, resource_UI_node_path: String, agent_name: String) -> Node:
	var agent = agent_scene.instantiate()
	
	agent.name = agent_name
	add_child(agent)
	agent._initilize_agent(spawn_position, main_building_scene_path, resource_UI_node_path, agent_name)
	
	return agent
	
# Spawn an agent at the specified position with a given name
func spawn_grim_reaper(spawn_position: Vector2):
	var grim_reaper = grim_reaper_scene.instantiate()
	grim_reaper.position = spawn_position
	add_child(grim_reaper)
