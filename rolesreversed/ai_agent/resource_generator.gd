@tool

extends Node

@export var faction_data: Resource

@export var agent_owner : Node = null
var PRIMARY_RESOURCE_per_base : int = 0
var SECONDARY_RESOURCE_per_base : int = 0

var PRIMARY_RESOURCE_per_outpost : int = 0
var SECONDARY_RESOURCE_per_outpost : int = 0

var PRIMARY_RESOURCE_per_unit : int = 0
var SECONDARY_RESOURCE_per_unit : int = 0

var PRIMARY_RESOURCE_per_tick : int = 0
var SECONDARY_RESOURCE_per_tick : int = 0

func _ready():
    var timer = Timer.new()
    
    timer.wait_time = 1.0
    timer.one_shot = false
    timer.autostart = true
    timer.connect("timeout", Callable(self, "_on_timer_timeout"))
    add_child(timer)
    

    call_deferred("initialize_agent_owner")

func initialize_agent_owner():
    var parent = get_parent()
    agent_owner = parent.get_agent_owner()
    if not agent_owner:
        print("ERROR: Agent owner not set!")
        return


func _on_timer_timeout():
    update_resources()
    print("Timer ticked, resources updated.")

func update_resources():
    if not agent_owner:
        print("ERROR: Agent owner not set!")
        return
    
    if not agent_owner.has_node("Resources"):
        print("ERROR: Resources node not found in agent owner!")
        return
    
    PRIMARY_RESOURCE_per_tick = 50
    SECONDARY_RESOURCE_per_tick = 0

    var buildings_node = agent_owner.get_node("Buildings")
    if buildings_node and buildings_node.has_method("get_children"):
        for building in buildings_node.get_children():
            PRIMARY_RESOURCE_per_tick += faction_data.PRIMARY_RESOURCE_per_base
            SECONDARY_RESOURCE_per_tick += faction_data.SECONDARY_RESOURCE_per_base
    else:
        print("ERROR: Buildings node is not iterable or does not exist!")

    var army_node = agent_owner.get_node("Army")
    for unit in army_node.get_children():
        PRIMARY_RESOURCE_per_tick += faction_data.PRIMARY_RESOURCE_per_unit
        SECONDARY_RESOURCE_per_tick += faction_data.SECONDARY_RESOURCE_per_unit

    print("Primary Resource per tick: ", PRIMARY_RESOURCE_per_tick)
    print("Secondary Resource per tick: ", SECONDARY_RESOURCE_per_tick)

    agent_owner.add_resources(PRIMARY_RESOURCE_per_tick, SECONDARY_RESOURCE_per_tick)
