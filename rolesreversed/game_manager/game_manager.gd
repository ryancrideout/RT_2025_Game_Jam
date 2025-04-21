extends Control

@onready var agent_scene = preload("res://ai_agent/master_agent.tscn")

func _ready():
	print("Game Manager scene is loaded and ready!")

func _on_play_button_pressed():
	# Spawn two agents with different positions and names
	spawn_agent(Vector2(1200, 3000), "res://ai_agent/skeleton_castle.tscn", "SkeletonAgent")
	spawn_agent(Vector2(9200, 3000), "res://ai_agent/skeleton_castle.tscn", "HumanAgent")
	
	print("Spawned two agents!")
	
	# Demo: Test resource system after a short delay
	await get_tree().create_timer(1.0).timeout
	#test_resource_system(agent1)

# Spawn an agent at the specified position with a given name
func spawn_agent(spawn_position: Vector2, main_building_scene_path: String, agent_name: String) -> Node:
	var agent = agent_scene.instantiate()
	
	add_child(agent)
	agent._initilize_agent(spawn_position, main_building_scene_path, agent_name)
	
	return agent

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
