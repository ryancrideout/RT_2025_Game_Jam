extends CharacterBody2D

var speed: float = 6400.0
var lifetime: float = 20.0
@onready var _animated_sprite = $AnimatedSprite2D

var states = {
	0: "Idle",
	1: "Movement",
	2: "Windup",
	3: "Attacking"
}
var state
var active_states = [states[2], states[3]]

func _ready():
	set_process(true)
	state = states[0]

func _physics_process(delta: float) -> void:
	velocity.x = speed * delta
	move_and_slide()
	
func _process(delta: float):
	# position.x += speed * delta
	sprite_management()
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func sprite_management():
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
