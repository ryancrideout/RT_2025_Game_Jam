extends VBoxContainer

var agent_owner: Node = null
var resources_node: Node = null
var primary_label: Label
var secondary_label: Label
var building_label: Label

var basic_unit_label: Label
var kill_label: Label

func _agent_init() -> void:

    if agent_owner and agent_owner.has_node("Resources"):
        agent_owner.connect("building_changed", Callable(self, "_on_building_changed"))
        building_label = $HBoxContainer2/Outposts  # Adjust this path to match your UI structure
        resources_node = agent_owner.get_node("Resources")

    if agent_owner and agent_owner.has_node("Army"):
        agent_owner.connect("unit_changed", Callable(self, "update_basic_unit_display"))
        basic_unit_label = $HBoxContainer/BasicUnit  # Adjust this path to match your UI structure

    primary_label = $HBoxContainer/PrimaryResource  # Adjust this path to match your UI structure
    #secondary_label = $SecondaryLabel
    #print("Agent UI initialized with resources node: ", resources_node)
    resources_node.connect("resource_changed", Callable(self, "_on_resource_changed"))
    #resources_node.connect("resources_depleted", Callable(self, "_on_resources_depleted"))
    kill_label = $HBoxContainer3/Kills  # Adjust this path to match your UI structure
    resources_node.connect("log_kill", Callable(self, "update_kill_display"))

func _on_resource_changed(resource_type, new_value):
    # Update UI or game logic based on resource changes
    if resource_type == "primary":
        update_primary_display(new_value)
    # elif resource_type == "secondary":
    #     update_secondary_display(new_value)

func _on_building_changed(new_value):
    # Update the building display
    if building_label:
        building_label.text = str(new_value)
        #print("Building updated: ", new_value)

func update_primary_display(new_value):
    # Update the primary resource display
    if primary_label:
        primary_label.text = str(new_value)
        #print("Primary resource updated: ", new_value)

func update_basic_unit_display(new_value):
    # Update the basic unit display
    if basic_unit_label:
        basic_unit_label.text = str(new_value)
        #print("Basic unit updated: ", new_value)

func update_kill_display(increment):
    # Update the kill display
    if kill_label:
        kill_label.text = str(kill_label.text.to_int() + increment)

func set_agent_owner(agent: Node) -> void:
    agent_owner = agent

func get_agent_owner() -> Node:
    return agent_owner
