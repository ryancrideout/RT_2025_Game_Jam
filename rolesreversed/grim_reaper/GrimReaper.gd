extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D
@export var speed = 400

func _process(_delta):
	_animated_sprite.play("Idle")
	
func get_input():
	var input_direction = Input.get_vector("a", "d", "w", "s")
	velocity = input_direction * speed
	
func _physics_process(delta: float) -> void:
	get_input()
	move_and_slide()

#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventKey:
		#if event.keycode == KEY_D:
			#position.x += 5.0
#
		#if event.keycode == KEY_A:
			#position.x -= 5.0
#
		#if event.keycode == KEY_W:
			#position.y -= 5.0
#
		#if event.keycode == KEY_S:
			#position.y += 5.0
