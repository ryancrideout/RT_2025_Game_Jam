extends Node2D

# Reference to resources
var resources = null
var main_building_scene: PackedScene
var main_building_position: Vector2

# Reference to buildings node
var buildings_node = null
@export var buildings = []

signal building_changed(new_value: int)
signal unit_changed(new_value: int)

func _ready():
	spawn_unit_timer()
	
func _initilize_agent(spawn_position: Vector2,
					  main_building_scene_path: String,
					  resource_UI_node_path: NodePath,
					  agent_name: String = "Agent") -> void:
	
	main_building_position = spawn_position
	
	# Initialize resources
	resources = $Resources
	if not resources:
		print("ERROR: Resources node not found on agent!")
	else:
		print("Agent initialized with resources:")
		print("PRIMARY: ", resources.PRIMARY_RESOURCE)
		print("SECONDARY: ", resources.SECONDARY_RESOURCE)

		#Find the agent UI node for displaying resources and set it as the owner
		var resource_UI_node = get_node(resource_UI_node_path)
		print("Resource UI node found: ", resource_UI_node)
		resource_UI_node.set_agent_owner(self)
		resource_UI_node._agent_init()
		add_resources(200, 200)

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

	emit_signal("building_changed", buildings.size())

	print("Building spawned successfully!")
	return true

# Function to spawn a new unit if resources allow
func spawn_unit() -> bool: #building: Node2D
	if not resources:
		print("ERROR: Resources not available!")
		return false
	
	var army_size = self.get_node("Army").get_children().size()
	print("Army size: ", army_size)
	emit_signal("unit_changed", army_size)
	
		# Resource check passed and resources have been deducted

	if buildings.size() > 0:
		var unit_spawned = false

		for building in buildings:
			if building.has_method("spawn_unit"):
				# Check if we have enough resources
				if resources.try_spawn_unit():
					building.spawn_basic_unit()
					unit_spawned = true
				else:
					print("Failed to spawn unit: insufficient resources")
					return false
			else:
				print("WARNING: Building does not have spawn_unit method")

		if not unit_spawned:
			print("ERROR: No buildings were able to spawn a unit")
			return false     
	else:
		print("ERROR: No buildings in array")
		return false
	return true


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
	timer.name = "SpawnUnitTimer"
	timer.connect("timeout", Callable(self, "_on_spawn_unit_timer_timeout"))
	add_child(timer)
	timer.start()

func _on_spawn_unit_timer_timeout() -> void:
	spawn_unit()
