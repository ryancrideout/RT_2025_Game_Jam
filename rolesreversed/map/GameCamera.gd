extends Camera2D

var camera_width
var camera_height
var keyboard_step = 50
@onready var viewport_size = get_viewport().size

func _ready() -> void:
	set_width(viewport_size[0])
	set_height(viewport_size[1])
	var right_limit = 10000
	var bottom_limit = 10000
	set_limits(-10000, -10000, right_limit, bottom_limit)

func _physics_process(_delta: float) -> void:

	if Input.is_action_pressed("ui_right"):
		if position.x < (limit_right - camera_width / 2.0):
			position.x += keyboard_step

	if Input.is_action_pressed("ui_left"):
		if position.x > (limit_left + camera_width / 2.0):
			position.x -= keyboard_step

	if Input.is_action_pressed("ui_up"):
		if position.y > (limit_top + camera_height / 2.0):
			position.y -= keyboard_step

	if Input.is_action_pressed("ui_down"):
		if position.y < (limit_bottom - camera_height / 2.0):
			position.y += keyboard_step
			
	if Input.is_action_just_released('mouse_wheel_down'):
		zoom.x -= 0.05
		zoom.y -= 0.05
		
	if Input.is_action_just_released('mouse_wheel_up'):
		zoom.x += 0.05
		zoom.y += 0.05

func set_width(new_width: int):
	camera_width = new_width

func set_height(new_height: int):
	camera_height = new_height
	
# This sets the camera limits
func set_limits(new_limit_left: int, new_limit_top: int, new_limit_right: int, new_limit_bottom: int):
	limit_left = new_limit_left
	limit_top = new_limit_top
	limit_right = new_limit_right
	limit_bottom = new_limit_bottom
