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

@export var resource_UI_node_label: NodePath