extends Node2D

class_name Building

# Signals
signal spawn_completed(unit_instance)
signal spawn_failed(reason)

# Configuration
@export var spawn_radius: float = 150.0  # Distance from building to spawn units
@export var spawn_attempts: int = 10  # Max attempts to find spawn position
@export var spawn_min_clearance: float = 50.0  # Minimum distance between spawned units
var health := 200
@onready var health_bar = $HealthBar

# References
var parent_building: Node = null
var agent_owner: Node = null

@export var faction_data: Resource

func _ready():

    if not faction_data:
        push_error("Invalid or missing faction data!")
        return
        
    # Get reference to the parent building
    parent_building = get_parent()
    
    # Try to find the agent that owns this building
    if parent_building and parent_building.has_method("get_agent_owner"):
        agent_owner = parent_building.get_agent_owner()

    spawn_outpost_timer()

func _process(_delta: float) -> void:

    health_bar.value = health
    if health <= 0:
        if self.name == "MainBuilding":
            # If the main building is destroyed, end the game
            var grim_reaper = get_tree().get_root().get_node("Game/GameManager/GrimReaper")
            if grim_reaper:
                grim_reaper.game_over()
        else:
            queue_free()

func set_agent_owner(agent: Node) -> void:
    agent_owner = agent

func get_agent_owner() -> Node:
    return agent_owner



# Main function to spawn a unit
func spawn_unit(unit_scene: PackedScene, unit_name: String, spawn_position = null) -> Node2D:

    if not unit_scene:
        emit_signal("spawn_failed", "Invalid unit scene")
        return null
        
    # Try to find a valid spawn position
    if not spawn_position:
        spawn_position = find_valid_spawn_position()
    
    if spawn_position == Vector2.ZERO:
        emit_signal("spawn_failed", "No valid spawn position found")
        return null
        
    # Instance the unit
    var unit_instance = unit_scene.instantiate()
    if not unit_instance:
        emit_signal("spawn_failed", "Failed to instantiate unit")
        return null
        
    # Setup unit properties
    unit_instance.position = spawn_position
    #unit_instance.set_owner(agent_owner)
    unit_instance.set_name(unit_name + "_" + "%06X" % int(randf_range(0, 0xFFFFFF)))
    
    var army_node = agent_owner.get_node("Army")
    if army_node.get_child_count() > 60:
        #emit_signal("spawn_failed", "Army size limit exceeded")
        return null
    # Add unit to the proper parent
    if agent_owner and agent_owner.has_node("Army"):
        agent_owner.get_node("Army").add_child(unit_instance)
    else:
        # Fallback: add to the same parent as the building
        get_parent().get_parent().add_child(unit_instance)
    
    # Initialize the unit (if it has initialization method)
    if unit_instance.has_method("initialize") and agent_owner:
        unit_instance.initialize(agent_owner)
    
    emit_signal("spawn_completed", unit_instance)
    return unit_instance

# Find a valid position to spawn a unit
func find_valid_spawn_position() -> Vector2:
    for attempt in range(spawn_attempts):
        # Generate a random angle in the allowed ranges
        var angle: float
        if randf() < 0.5:
            # First range: 0 to 2/3π
            angle = randf_range(0, PI / 2)
        else:
            # Second range: 4/3π to 2π
            angle = randf_range(PI * 3 / 2, TAU)
        
        var faction_direction = faction_data.faction_direction
        # Flip the angle if faction_direction is -1
        if faction_direction == -1:
            angle += PI

        # Calculate potential spawn position
        var offset = Vector2(cos(angle), sin(angle)) * spawn_radius
        var potential_position = global_position + offset
        
        # Check if position is valid
        if is_position_clear(potential_position):
            return potential_position
    
    # If no valid position found after all attempts
    return Vector2.ZERO

# Check if a position is clear of obstacles
func is_position_clear(pos: Vector2) -> bool:
    # Get all units in scene to check for overlap
    var units = get_tree().get_nodes_in_group("Army")
    
    for unit in units:
        if unit.global_position.distance_to(pos) < spawn_min_clearance:
            return false
            
    return true

#
# Public methods called by the agent AI
#

func spawn_basic_unit():
    self.spawn_unit(faction_data.basic_unit_scene, faction_data.basic_unit_name)

func spawn_basic_free_unit(spawn_position):
    self.spawn_unit(faction_data.basic_unit_scene, faction_data.basic_unit_name, spawn_position)

func spawn_ranged_unit():
    self.spawn_unit(faction_data.ranged_unit_scene, faction_data.ranged_unit_name)

func spawn_special_unit():
    self.spawn_unit(faction_data.special_unit_scene, faction_data.special_unit_name)


func spawn_outpost_timer() -> void:
    var timer = Timer.new()
    timer.wait_time = 15.0
    timer.one_shot = false
    timer.name = "SpawnOutpostTimer"
    timer.connect("timeout", Callable(self, "_on_spawn_outpost_timer_timeout"))
    add_child(timer)
    timer.start()
    
func _on_spawn_outpost_timer_timeout() -> void:
    var current_position = self.position
    #print("current_position: ", current_position)
    var new_spawn_position = current_position + Vector2(randf_range(0, 1000) * faction_data.faction_direction, randf_range(-1000, 1000))

    new_spawn_position.y = clamp(new_spawn_position.y, 3000, 7000)
    #print("new_spawn_position: ", new_spawn_position)



    var resources = agent_owner.get_node("Resources")
    var buildings_node = agent_owner.get_node("Buildings")
    if not resources:
        print("ERROR: Resources not available!")
        pass

    if not buildings_node:
        print("ERROR: Buildings node not available!")
        pass

    if resources.try_spawn_outpost():
        var outpost_scene_path = faction_data.outpost_scene_path
        var outpost_scene = load(outpost_scene_path)
        self.spawn_outpost(outpost_scene, "NewOutpost", new_spawn_position)
    else:
        #print("Failed to spawn building: insufficient resources")
        pass

func spawn_outpost(outpost, outpost_name: String, new_spawn_position) -> void:
    agent_owner.spawn_building(outpost, outpost_name, new_spawn_position)

func receive_damage(incoming_damage):
    health -= incoming_damage
