extends Node2D

# Signals
signal spawn_completed(unit_instance)
signal spawn_failed(reason)

# Configuration
@export var spawn_radius: float = 150.0  # Distance from building to spawn units
@export var spawn_attempts: int = 10      # Max attempts to find spawn position
@export var spawn_min_clearance: float = 50.0  # Minimum distance between spawned units

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

func set_agent_owner(agent: Node) -> void:
    agent_owner = agent

func get_agent_owner() -> Node:
    return agent_owner



# Main function to spawn a unit
func spawn_unit(unit_scene: PackedScene) -> Node2D:
    if not unit_scene:
        emit_signal("spawn_failed", "Invalid unit scene")
        return null
        
    # Try to find a valid spawn position
    var spawn_position = find_valid_spawn_position()
    
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
    
    # Add unit to the proper parent
    if agent_owner and agent_owner.has_node("Units"):
        agent_owner.get_node("Units").add_child(unit_instance)
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
        # Generate random angle around the building
        var angle = randf() * TAU  # TAU is 2*PI
        
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
    var units = get_tree().get_nodes_in_group("units")
    
    for unit in units:
        if unit.global_position.distance_to(pos) < spawn_min_clearance:
            return false
    
    # TODO: Add physics/area check if needed for terrain obstacles
    # var space_state = get_world_2d().direct_space_state
    # var query = PhysicsRayQueryParameters2D.create(global_position, pos)
    # var result = space_state.intersect_ray(query)
    # if result:
    #     return false
            
    return true


#
# Public methods called by the agent AI
#

func spawn_basic_unit():
    return spawn_unit(faction_data.basic_unit_scene)

func spawn_ranged_unit():
    return spawn_unit(faction_data.ranged_unit_scene)

func spawn_special_unit():
    return spawn_unit(faction_data.special_unit_scene)