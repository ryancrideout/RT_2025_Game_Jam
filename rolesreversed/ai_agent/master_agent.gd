extends Node2D

# Reference to resources
var resources = null
var main_building_scene: PackedScene
var main_building_position: Vector2

# Reference to buildings node
var buildings_node = null
@export var buildings = []

var skeleton_scene: PackedScene = preload("skeleton.tscn")

func _ready():
	spawn_unit_timer()
	
func _initilize_agent(spawn_position: Vector2,
					  main_building_scene_path: String,
					  agent_name: String = "Agent") -> void:
	# Initialize resources
	resources = $Resources
	if not resources:
		print("ERROR: Resources node not found on agent!")
	else:
		print("Agent initialized with resources:")
		print("PRIMARY: ", resources.PRIMARY_RESOURCE)
		print("SECONDARY: ", resources.SECONDARY_RESOURCE)

	# Find the Buildings node in the scene
	buildings_node = $Buildings
	if not buildings_node:
		print("ERROR: 'Buildings' node not found!")
		# Create a Buildings node if it doesn't exist
		buildings_node = Node2D.new()
		buildings_node.name = "Buildings"
		get_parent().add_child(buildings_node)
		print("Created new Buildings node")

	# Load the main building scene
	main_building_scene = load(main_building_scene_path)
	if not main_building_scene:
		print("ERROR: Main building scene not found!")
	else:
		print("Main building scene loaded successfully!")

		spawn_building(main_building_scene, "MainBuilding", spawn_position)
		print("Main building for ", agent_name, " spawned at position: ", spawn_position)


# Function to spawn the main building
func spawn_building(building_scene: PackedScene, building_name, building_position) -> bool:
	if not resources:
		print("ERROR: Resources not available!")
		return false
	
	if not buildings_node:
		print("ERROR: Buildings node not available!")
		return false
	
	# Instantiate and add the building
	var building = building_scene.instantiate()
	building.name = building_name
	building.position = building_position
		
	buildings_node.add_child(building)

	# Set the building's owner to this agent
	if building.has_method("set_agent_owner"):
		building.set_agent_owner(self)
		buildings.append(building)
		print("Building added to buildings array. Current size: ", buildings.size())
	else:
		print("WARNING: Building does not have set_agent_owner method")

	print("Building spawned successfully!")
	return true

# Function to spawn a new unit if resources allow
func spawn_unit(unit_type: String = "skeleton",
				unit_scene: PackedScene = skeleton_scene) -> bool: #building: Node2D
	if not resources:
		print("ERROR: Resources not available!")
		return false
	
	# Check if we have enough resources
	if resources.try_spawn_unit():
		# Resource check passed and resources have been deducted
		print("Spawning unit: ", unit_type)
		if buildings.size() > 0:
			if buildings[0].has_method("request_spawn"):
				buildings[0].request_spawn(unit_scene)
			else:
				print("ERROR: Building does not have request_spawn method")
				return false
		else:
			print("ERROR: No buildings in array")
			return false
			
		return true
	else:
		print("Failed to spawn unit: insufficient resources")
		return false

# Function to add resources (for gathering/income)
func add_resources(primary_amount: float, secondary_amount: float) -> void:
	if resources:
		resources.update_primary_resource(primary_amount)
		resources.update_secondary_resource(secondary_amount)
		print("Resources updated - PRIMARY: ", resources.PRIMARY_RESOURCE, " SECONDARY: ", resources.SECONDARY_RESOURCE)

func spawn_unit_timer() -> void:
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.connect("timeout", Callable(self, "_on_spawn_unit_timer_timeout"))
	add_child(timer)
	timer.start()

func _on_spawn_unit_timer_timeout() -> void:
	spawn_unit()
