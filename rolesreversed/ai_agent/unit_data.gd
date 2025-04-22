# UnitData.gd
@tool                         # lets you edit in the Inspector

extends Resource
class_name UnitData


@export var display_name := ""
@export var unit_scene  : PackedScene      # visuals + behaviour (prefab)
@export var costs       : Dictionary = {   # fully generic
    "PRIMARY": 5,
    "SECONDARY": 0
}
@export var max_hp      : int  = 10
@export var move_speed  : float = 8.0
@export var base_damage : int  = 2
@export var bounty      : int  = 3        # reward on death
