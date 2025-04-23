extends CharacterBody2D

class_name Human
#spawn_free_unit
var target = null
var health := 35.0
var damage := 7.5
var speed: float = -4800.0
var lifetime: float = 2000.0
@onready var _animated_sprite = $AnimatedSprite2D
@onready var health_bar = $HealthBar

var stasis_timer = Timer.new()

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

func _ready():
	set_process(true)
	state = states[0]

	stasis_timer.wait_time = 12.0
	stasis_timer.one_shot = true
	stasis_timer.autostart = false
	stasis_timer.connect("timeout", Callable(self, "_on_stasis_timeout"))
	add_child(stasis_timer)
	
func _physics_process(delta: float) -> void:
	# If not dying
	if state != states[4]:
		velocity.x = speed * delta
		move_and_slide()
	else:
		velocity = Vector2.ZERO
	
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
		if velocity.x > 0:
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
			state = states[0]

func stasis():
	set_collision_layer(0)
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
			# Revive the unit
			var skeleton_agent = area.get_parent()
			if skeleton_agent.has_method("spawn_basic_free_unit"):
				skeleton_agent.spawn_basic_free_unit(position)
				queue_free()
			else:
				print("ERROR: Skeleton agent does not have spawn_basic_free_unit method")
				return
			return
	queue_free()

func is_still_valid_target(body) -> bool:
	if is_instance_valid(body):
		if body is Building:
			return true
		if body.state != states[4]:
			return true
		else:
			return false
	else:
		return false

func receive_damage(incoming_damage):
	health -= incoming_damage

func _on_attack_range_body_entered(body: Node2D) -> void:
	if body is StaticBody2D:
		if body.get_parent() is Building:
			if body.get_parent().faction_data.faction_name == "Undead":
				target = body.get_parent()
	if body is Skeleton:
		target = body

func update_health_bar():
	if health_bar.value > health:
		health_bar.value -= 0.5
	else:
		health_bar.value += 0.5
