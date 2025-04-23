@tool                         # lets you edit in the Inspector

extends Resource
class_name FactionData

@export var faction_name: String
@export var basic_unit_scene: PackedScene
@export var basic_unit_name: String

@export var ranged_unit_scene: PackedScene
@export var ranged_unit_name: String

@export var special_unit_scene: PackedScene
@export var special_unit_name: String

@export var outpost_scene_path: String
@export var outpost_name: String

@export var faction_direction: int

@export var resource_UI_node_label: NodePath

@export var PRIMARY_RESOURCE_per_base : int
@export var SECONDARY_RESOURCE_per_base : int

@export var PRIMARY_RESOURCE_per_outpost : int
@export var SECONDARY_RESOURCE_per_outpost : int

@export var PRIMARY_RESOURCE_per_unit : int
@export var SECONDARY_RESOURCE_per_unit : int
