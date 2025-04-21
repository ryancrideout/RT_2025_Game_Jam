extends Node2D

var speed: float = 100.0
var lifetime: float = 20.0

func _ready():
    set_process(true)

func _process(delta: float):
    position.x += speed * delta
    lifetime -= delta
    if lifetime <= 0:
        queue_free()