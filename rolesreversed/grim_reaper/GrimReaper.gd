extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D
@onready var camera = $PlayerCamera
@onready var hitbox = $Hitbox
@onready var hitbox_shape = $Hitbox/HitboxShape
@export var speed = 625

var states = {
	0: "Idle",
	1: "Movement",
	2: "Windup",
	3: "Attacking"
}
var state
var active_states = [states[2], states[3]]
var attack_position = Vector2.ZERO
var damage = 20.0

func _ready() -> void:
	camera.make_current()
	# Default state is idle state
	state = states[0]

func _process(_delta):
	state_management()
	sprite_management()

func _physics_process(_delta: float) -> void:
	get_input()
	move_and_slide()

func get_input():
	var input_direction = Input.get_vector("a", "d", "w", "s")
	velocity = input_direction * speed
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		attack_position = event.position
		state = states[2]

func sprite_management():
	if state not in active_states:
		if velocity != Vector2.ZERO:
			_animated_sprite.offset.y = 10
			_animated_sprite.play("Movement")
		else:
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
		_animated_sprite.offset.y = 0
		_animated_sprite.play(states[2])

	# Attacking
	if state == states[3]:
		if attack_position.x < (camera.camera_width / 2.0):
			_animated_sprite.flip_h = true
		else:
			_animated_sprite.flip_h = false
		_animated_sprite.offset.y = 0
		_animated_sprite.play(states[3])

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
	
	# Attack has finished
	if _animated_sprite.animation == states[3]:
		# Set state to idle.
		state = states[0]
