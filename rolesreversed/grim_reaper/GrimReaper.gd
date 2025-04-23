extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D
@onready var camera = $PlayerCamera
var camera_adjustment = Vector2(576.0, 324.0)
@onready var hitbox = $Hitbox
@onready var hitbox_shape = $Hitbox/HitboxShape
@onready var ui = $UILayer/GrimReaperUI
@onready var _spell_animations = $SpellManager/SpellAnimations
@onready var _promote_hitbox = $SpellManager/PromoteHitbox
@onready var _stasis_hitbox = $SpellManager/StasisHitbox
@onready var _haste_hitbox = $SpellManager/HasteHitbox
@onready var _corpse_explosion_hitbox = $SpellManager/CorpseExplosionHitbox
@export var speed = 625
var secondary_resource

var agent_owner: Node = null

var states = {
	0: "Idle",
	1: "Movement",
	2: "Windup",
	3: "Attacking",
	4: "Casting",
	5: "Casted",
}
var state
var active_states = [states[2], states[3], states[4], states[5]]
var attack_position = Vector2.ZERO
var spell_position = Vector2.ZERO
var damage = 20.0
var spell_costs = {
	"Promote": 625,
	"Stasis": 1240,
	"Haste": 1880,
	"Corpse_Explosion": 320
}
var casting_spell
var spell_queue = []
var ticks = 0

func _ready() -> void:
	# Connect the button signals
	ui.connect("promote_button_pressed", begin_cast)
	ui.connect("stasis_button_pressed", begin_cast)
	ui.connect("haste_button_pressed", begin_cast)
	ui.connect("corpse_explosion_button_pressed", begin_cast)
	
	# Make the camera current
	camera.make_current()
	
	# Default state is idle state
	state = states[0]

func _process(_delta):
	# print(agent_owner.resources.get_resources())
	# agent_owner.resources.update_secondary_resource(cost)
	state_management()
	sprite_management()

func _physics_process(_delta: float) -> void:
	get_input()
	move_and_slide()
	
	if spell_queue != []:
		ticks += 1
		if ticks > 1:
			ticks = 0
			var active_spell = spell_queue.pop_front()
			match active_spell:
				"Promote":
					_spell_animations.play("Promote")
					var victims = _promote_hitbox.get_overlapping_bodies()
					for victim in victims:
						if victim is Human or victim is Skeleton:
							victim.apply_promote()
				"Haste":
					_spell_animations.play("Haste")
					var victims = _haste_hitbox.get_overlapping_bodies()
					for victim in victims:
						if victim is Human or victim is Skeleton:
							victim.apply_haste()
				"Stasis":
					_spell_animations.play("Stasis")
					var victims = _stasis_hitbox.get_overlapping_bodies()
					for victim in victims:
						if victim is Human or victim is Skeleton:
							victim.apply_stasis()
				"Corpse_Explosion":
					var found_corpse = false
					var victims = _corpse_explosion_hitbox.get_overlapping_bodies()
					for victim in victims:
						if victim is Human or victim is Skeleton:
							if victim.state == "Stasis":
								found_corpse = true
								victim.apply_corpse_explosion()
								_spell_animations.play("Corpse_Explosion")
					# If we didn't find a corpse, refund the resource cost.
					if not found_corpse:
						agent_owner.resources.update_secondary_resource(spell_costs["Corpse_Explosion"])
	

func get_input():
	var input_direction = Input.get_vector("a", "d", "w", "s")
	velocity = input_direction * speed
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		attack_position = event.position
		state = states[2]
		
	if state == states[4]:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			# Cast spell function here
			# spell_position = event.position
			spell_position = (event.position + camera.position - camera_adjustment)
			
			cast_spell()
			state = states[5]
			
func begin_cast(spell_name):
	# Check resources
	secondary_resource = agent_owner.resources.get_resources()["secondary"]
	if spell_costs[spell_name] > secondary_resource:
		return
	else:
		# Set to casting state:
		casting_spell = spell_name
		state = states[4]
		
func cast_spell():
	# Need to actually have spell logic here.
	match casting_spell:
		"Promote":
			_spell_animations.position = spell_position
			_spell_animations.scale = Vector2(1.0, 1.0)
			_promote_hitbox.position = spell_position
			# Throw it in a queue so that it gets picked up the next
			# Physics tick.
			spell_queue.append(casting_spell)

		"Stasis":
			_spell_animations.position = spell_position
			_spell_animations.scale = Vector2(1.0, 1.0)
			_stasis_hitbox.position = spell_position
			# Throw it in a queue so that it gets picked up the next
			# Physics tick.
			spell_queue.append(casting_spell)
			
		"Haste":
			_spell_animations.position = spell_position
			_spell_animations.scale = Vector2(1.0, 1.0)
			_haste_hitbox.position = spell_position
			# Throw it in a queue so that it gets picked up the next
			# Physics tick.
			spell_queue.append(casting_spell)
			
		"Corpse_Explosion":
			_spell_animations.position = spell_position
			_spell_animations.scale = Vector2(3.0, 3.0)
			_corpse_explosion_hitbox.position = spell_position
			# Throw it in a queue so that it gets picked up the next
			# Physics tick.
			spell_queue.append(casting_spell)
			
	agent_owner.resources.update_secondary_resource(-spell_costs[casting_spell])
	
func sprite_management():
	if state not in active_states:
		if velocity != Vector2.ZERO:
			_animated_sprite.offset.x = 0
			_animated_sprite.offset.y = 10
			_animated_sprite.play("Movement")
		else:
			_animated_sprite.offset.x = 0
			_animated_sprite.offset.y = 20
			_animated_sprite.play("Idle")
			
		# Flip the sprite, if applicable. 
		if velocity.x >= 0:
			_animated_sprite.flip_h = false
		else:
			_animated_sprite.flip_h = true

	# Windup
	if state == states[2]:
		if attack_position.x < (camera.camera_width / 2.0):
			_animated_sprite.flip_h = true
		else:
			_animated_sprite.flip_h = false
		_animated_sprite.offset.x = 0
		_animated_sprite.offset.y = 0
		_animated_sprite.play(states[2])

	# Attacking
	if state == states[3]:
		if attack_position.x < (camera.camera_width / 2.0):
			_animated_sprite.flip_h = true
		else:
			_animated_sprite.flip_h = false
		_animated_sprite.offset.x = 0
		_animated_sprite.offset.y = 0
		_animated_sprite.play(states[3])
	
	# Casting
	if state == states[4]:
		_animated_sprite.offset.x = 0
		_animated_sprite.offset.y = 0
		_animated_sprite.play(states[4])
		
	# Casted
	if state == states[5]:
		if spell_position.x < (camera.camera_width / 2.0):
			_animated_sprite.offset.x = -20
			_animated_sprite.flip_h = true
		else:
			_animated_sprite.offset.x = 20
			_animated_sprite.flip_h = false
		_animated_sprite.offset.y = 0
		_animated_sprite.play(states[5])

func state_management() -> void:
		if state not in active_states:
			if velocity != Vector2.ZERO:
				# Set state to Movement
				state = states[1]
			else:
				# Set state to Idle
				state = states[0]

func _on_animated_sprite_2d_animation_finished() -> void:
	# Windup has finished
	if _animated_sprite.animation == states[2]:
		# Flip the attack hitbox if we need to.
		if _animated_sprite.flip_h == true:
			hitbox_shape.scale.x = -1.0
		else:
			hitbox_shape.scale.x = 1.0
			
		# Get the bodies, apply damage.
		var victims = hitbox.get_overlapping_bodies()
		for victim in victims:
			if victim is Human or victim is Skeleton:
				victim.receive_damage(damage)

		# State is attacking
		state = states[3]
	
	# Attack or Spell has finished
	if _animated_sprite.animation == states[3] or _animated_sprite.animation == states[5]:
		# Set state to idle.
		state = states[0]

func set_agent_owner(agent: Node) -> void:
	agent_owner = agent

func get_agent_owner() -> Node:
	return agent_owner
