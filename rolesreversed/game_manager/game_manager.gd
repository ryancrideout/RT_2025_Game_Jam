extends Control

@onready var agent_scene = preload("res://ai_agent/master_agent.tscn")
@onready var grim_reaper_scene = preload("res://grim_reaper/GrimReaper.tscn")

func _ready():
	print("Game Manager scene is loaded and ready!")

func _on_play_button_pressed():
	# Spawn two agents with different positions and names
	spawn_agent(Vector2(3500, 5000), "res://ai_agent/skeleton_castle.tscn", "/root/Game/CanvasLayer/Control/AgentUI/VBoxContainer/ResourcesContainer/HBoxContainer/UndeadVBoxContainer", "SkeletonAgent")
	spawn_agent(Vector2(6500, 5000), "res://ai_agent/human_castle.tscn", "/root/Game/CanvasLayer/Control/AgentUI/VBoxContainer/ResourcesContainer/HBoxContainer/HumanVBoxContainer", "HumanAgent")
	
	print("Spawned two agents!")
	
	spawn_grim_reaper(Vector2(5000, 5000))
	
	# Demo: Test resource system after a short delay
	await get_tree().create_timer(1.0).timeout
	#test_resource_system(agent1)

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


# Function to test the resource system
func test_resource_system(agent):
	print("\n--- Testing Resource System ---")
	
	# Try to spawn a unit (should succeed with default resources)
	print("Attempting to spawn first unit...")
	var success = agent.spawn_unit()
	
	# Add some resources
	print("\nAdding more resources...")
	agent.add_resources(15, 5)
	
	# Try to spawn another unit (should succeed)
	print("\nAttempting to spawn second unit...")
	success = agent.spawn_unit()
	
	# Try to spawn too many units to deplete resources
	print("\nAttempting to spawn many units to test resource depletion...")
	for i in range(10):
		await get_tree().create_timer(0.5).timeout
		success = agent.spawn_unit()
		if not success:
			print("Resource limit reached after " + str(i) + " additional units")
			break
