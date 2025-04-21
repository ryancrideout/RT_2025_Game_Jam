extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D
@onready var camera = $PlayerCamera
@export var speed = 625

func _ready() -> void:
	camera.make_current()

func _process(_delta):
	sprite_management()

func get_input():
	var input_direction = Input.get_vector("a", "d", "w", "s")
	velocity = input_direction * speed
	
func _physics_process(_sdelta: float) -> void:
	get_input()
	move_and_slide()

func sprite_management():
	if velocity != Vector2.ZERO:
		_animated_sprite.play("Movement")
	else:
		_animated_sprite.play("Idle")
		
	# Flip the sprite, if applicable. 
	if velocity.x >= 0:
		_animated_sprite.flip_h = false
	else:
		_animated_sprite.flip_h = true
