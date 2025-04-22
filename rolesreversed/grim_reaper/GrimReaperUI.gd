extends Control

@onready var promote_button = $HBoxContainer/PromoteButton
@onready var stasis_button = $HBoxContainer/StasisButton
@onready var haste_button = $HBoxContainer/HasteButton
@onready var corpse_explosion_button = $HBoxContainer/CorpseExplosionButton


func _on_promote_button_pressed() -> void:
	print("Promote button pressed!")

func _on_stasis_button_pressed() -> void:
	print("Stasis button pressed!")

func _on_haste_button_pressed() -> void:
	print("Haste button pressed!")

func _on_corpse_explosion_button_pressed() -> void:
	print("Corpse Explosion button pressed!")
