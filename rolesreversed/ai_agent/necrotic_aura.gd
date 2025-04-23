extends Area2D

@export var max_radius: float = 5000.0
@export var grow_speed: float = 50.0     # units/sec
@export var decay_speed: float = 100.0
@export var rotation_speed: float = 15.0

@export var incoming_damage: float = 0.5

var target_radius: float = 0.0
var current_radius: float = 0.0
var resources_node: Node

var shape: CircleShape2D

func _ready():
    call_deferred("initialize_aura")

func initialize_aura():

    var parent_node = self.get_parent()
    #print("Parent node: ", parent_node)
    if not parent_node:
        print("ERROR: Parent node not found!")
        return
    
    if not parent_node.has_method("get_agent_owner"):
        print("ERROR: Parent node does not have method 'get_agent_owner'")
        return
    
    var agent_owner = parent_node.get_agent_owner()

    
    #print(agent_owner)
    if not agent_owner:
        print("ERROR: get_agent_owner() returned null!")
        return
    
    if agent_owner.has_node("Resources"):
        resources_node = agent_owner.get_node("Resources")
    else:
        print("ERROR: Resources node not found in agent_owner!")
        return
    
    shape = $CollisionShape2D.shape
    if not shape:
        print("ERROR: CircleShape2D not found!")
        return
    shape.radius = current_radius

    if resources_node:
        resources_node.connect("resource_changed", Callable(self, "_on_resource_changed"))

    start_damage_timer()

func _process(delta):
    if current_radius < target_radius:
        current_radius = min(current_radius + grow_speed * delta, target_radius)
    elif current_radius > target_radius:
        current_radius = max(current_radius - decay_speed * delta, target_radius)

    shape.radius = current_radius

    var sprite = $CollisionShape2D/Sprite2D
    if sprite:
        sprite.scale = Vector2(current_radius / sprite.texture.get_width(), current_radius / sprite.texture.get_height())
        sprite.rotation_degrees += rotation_speed * delta

func _on_resource_changed(resource_type, new_value):
    if resource_type == "secondary":
        var ratio :float = clamp(float(new_value) / max_radius, 0.0, 1.0)
        target_radius = ratio * max_radius

func start_damage_timer():
    var timer = Timer.new()
    timer.wait_time = 1.0
    timer.one_shot = false
    timer.autostart = true
    timer.connect("timeout", Callable(self, "_on_damage_timer_timeout"))
    add_child(timer)
    timer.start()

func _on_damage_timer_timeout():
    for body in self.get_overlapping_bodies():
        if body is Skeleton:
            body.receive_damage(-incoming_damage*0.2)
        elif body is Human:
            body.receive_damage(incoming_damage)