extends CharacterBody2D

class_name Skeleton

@export var target = null
@export var vision_target = null

@export var revive_cost: int = 1000
var health := 12.0
var damage := 8.0
var base_speed: float = 6400.0
var speed: float = 6400.0
var lifetime: float = 2000.0
var is_promoted = false
@onready var _animated_sprite = $AnimatedSprite2D
@onready var health_bar = $HealthBar
@onready var star_sprite = $Star
@onready var corpse_explosion_hitbox = $CorpseExplosionArea
var corpse_explosion_damage: float = 200.0

var stasis_timer = Timer.new()
var vision_timer = Timer.new()

var states = {
    0: "Idle",
    1: "Movement",
    2: "Windup",
    3: "Attacking",
    4: "Dying",
    5: "Stasis"
}

var state
var active_states = [states[2], states[3], states[4]]
var inactive_states = [states[4], states[5]]

func _ready():
    set_process(true)
    state = states[0]

    stasis_timer.wait_time = 12.0
    stasis_timer.one_shot = true
    stasis_timer.autostart = false
    stasis_timer.connect("timeout", Callable(self, "_on_stasis_timeout"))
    add_child(stasis_timer)

    vision_timer.wait_time = 1.0
    vision_timer.one_shot = false
    vision_timer.connect("timeout", Callable(self, "find_new_target_in_vision"))
    add_child(vision_timer)
    vision_timer.start()

func _physics_process(delta: float) -> void:
    # If not dying
    if state not in active_states:
        if is_instance_valid(vision_target):
            velocity = (vision_target.position - position).normalized() * speed * delta
        else:
            velocity = Vector2.RIGHT * speed * delta
        velocity.y = lerp(velocity.y, randf_range(-1000.0, 1000.0), 0.1)
        move_and_slide()
    else:
        velocity = Vector2.ZERO

    if position.x > 10000:
        queue_free()
    
func _process(delta: float):
    update_health_bar()
    sprite_management()
    lifetime -= delta
    # If lifetime hits zero and isn't already dying.
    if lifetime <= 0 and state != states[4]:
        die()
    
    if health <= 0 and state != states[4]:
        die()
        
    if target != null and state not in active_states:
        # Windup for attack
        state = states[2]

func sprite_management():
    if state == states[5]:
        _animated_sprite.play("Stasis")
    
    if state not in active_states:
        if velocity != Vector2.ZERO:
            _animated_sprite.play("Movement")
        else:
            _animated_sprite.play("Idle")
            
        # Flip the sprite, if applicable. 
        if velocity.x >= 0:
            _animated_sprite.flip_h = false
        else:
            _animated_sprite.flip_h = true
            
    # Windup
    if state == states[2]:
        if is_instance_valid(target):
            if target.position.x < position.x:
                _animated_sprite.flip_h = true
            else:
                _animated_sprite.flip_h = false
        _animated_sprite.play(states[2])
        
    # Attacking
    if state == states[3]:
        if is_instance_valid(target):
            if target.position.x < position.x:
                _animated_sprite.flip_h = true
            else:
                _animated_sprite.flip_h = false
        _animated_sprite.play(states[3])

func die():
    state = states[4]
    _animated_sprite.play("Dying")
    var agent_killer = get_node("/root/Game/GameManager/HumanAgent")
    agent_killer.log_kill()

func _on_animated_sprite_2d_animation_finished() -> void:
    if _animated_sprite.animation == "Dying":
        _animated_sprite.play("Stasis")
        stasis()
        
    if _animated_sprite.animation == "Windup":
        # Set state to be attacking
        state = states[3]
        if is_instance_valid(target):
            target.receive_damage(damage)
        
    if _animated_sprite.animation == "Attacking":
        if is_still_valid_target(target):
            # Windup for the next attack
            state = state[2]
        else:
            target = null
            vision_target = find_new_target_in_vision()
            state = states[0]

func stasis():
    set_collision_layer(2)
    set_collision_mask(0)
    
    health_bar.visible = false
    state = states[5]
    stasis_timer.start()
    set_process(false)
    set_physics_process(false)
  
func _on_stasis_timeout():
    
    var revive_aura = get_node("ReviveArea2D")
    var overlapping_areas = revive_aura.get_overlapping_areas()

    for area in overlapping_areas:
        if area is Area2D and area.has_method("initialize_aura"):
            var agent_owner_resources = get_node("/root/Game/GameManager/SkeletonAgent/Resources")
            
            if agent_owner_resources.SECONDARY_RESOURCE > revive_cost:
                agent_owner_resources.update_secondary_resource(-revive_cost)
                # Revive the unit
                
                _animated_sprite.animation = "Dying"
                _animated_sprite.speed_scale = -1.0  # Play in reverse
                _animated_sprite.frame = _animated_sprite.sprite_frames.get_frame_count("Dying") - 1  # Start at the last frame
                _animated_sprite.play()

                await _animated_sprite.animation_finished
                set_collision_layer(1)
                set_collision_mask(1)
                health_bar.visible = true
                health = 12.0
                lifetime = 2000.0
                health_bar.value = health_bar.max_value
                _animated_sprite.speed_scale = 1.0
                state = state[0]
                set_process(true)
                set_physics_process(true)
                return

    queue_free()

func is_still_valid_target(body) -> bool:
    if is_instance_valid(body):
        if body is Building:
            return true

        if body.state not in inactive_states:
            return true
        else:
            return false
    else:
        return false
        
func find_new_target_in_vision():
    if target == null:
        var vision_area = get_node("VisionArea2D")
        var overlapping_bodies = vision_area.get_overlapping_bodies()
        
        for body in overlapping_bodies:
            if body is StaticBody2D:
                if body is Building:
                    if body.get_parent().faction_data.faction_name == "Human":
                        vision_target = body.get_parent()
                        return
            if body is Human:
                if body.state != states[5]:  # Ensure the human is not in "Stasis"
                    vision_target = body
                return
    else:
        pass

func _on_attack_range_body_entered(body: Node2D) -> void:
    if body is StaticBody2D:
        if body.get_parent() is Building:
            if body.get_parent().faction_data.faction_name == "Human":
                target = body.get_parent()
    if body is Human:
        target = body

func receive_damage(incoming_damage):
    health -= incoming_damage

func update_health_bar():
    if health_bar.value > health:
        health_bar.value -= 0.5
    else:
        health_bar.value += 0.5

func apply_promote():
    if state not in inactive_states:
        is_promoted = true
        star_sprite.visible = true
        health_bar.max_value += 8.0
        health += 4.0
        damage += 1.5

func apply_haste():
    if state not in inactive_states:
        _animated_sprite.speed_scale += 0.1
        speed += 1700.0
        
func apply_stasis():
    if state not in inactive_states:
        _animated_sprite.speed_scale *= 0.5
        speed *= 0.1

func apply_corpse_explosion():
    if state == states[5]:
        var victims = corpse_explosion_hitbox.get_overlapping_bodies()
        for victim in victims:
            if victim is Human or victim is Skeleton:
                victim.receive_damage(corpse_explosion_damage)
        queue_free()
