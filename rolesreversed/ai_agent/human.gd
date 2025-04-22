extends CharacterBody2D

class_name Human

var target
var health := 35.0
var damage := 7.5
var speed: float = -4800.0
var lifetime: float = 20.0
@onready var _animated_sprite = $AnimatedSprite2D

var states = {
	0: "Idle",
	1: "Movement",
	2: "Windup",
	3: "Attacking",
	4: "Dying"
}
var state
var active_states = [states[2], states[3], states[4]]

func _ready():
	set_process(true)
	state = states[0]

func _physics_process(delta: float) -> void:
	# If not dying
	if state != states[4]:
		velocity.x = speed * delta
		move_and_slide()
	else:
		velocity = Vector2.ZERO
	
func _process(delta: float):
	# position.x += speed * delta
	sprite_management()
	lifetime -= delta
	# If lifetime hits zero and isn't already dying.
	if lifetime <= 0 and state != states[4]:
		die()
		
	if health <= 0:
		print("I was killed by society!!")
		die()

func sprite_management():
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

func die():
	state = states[4]
	_animated_sprite.play("Dying")

func _on_animated_sprite_2d_animation_finished() -> void:
	if _animated_sprite.animation == "Dying":
		queue_free()

func receive_damage(incoming_damage):
	health -= incoming_damage
