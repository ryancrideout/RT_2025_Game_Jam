extends Control

# @onready var promote_button = $HBoxContainer/PromoteButton
# @onready var stasis_button = $HBoxContainer/StasisButton
# @onready var haste_button = $HBoxContainer/HasteButton
# @onready var corpse_explosion_button = $HBoxContainer/CorpseExplosionButton

signal promote_button_pressed
signal stasis_button_pressed
signal haste_button_pressed
signal corpse_explosion_button_pressed

func _on_promote_button_pressed() -> void:
	promote_button_pressed.emit("Promote")

func _on_stasis_button_pressed() -> void:
	stasis_button_pressed.emit("Stasis")

func _on_haste_button_pressed() -> void:
	haste_button_pressed.emit("Haste")

func _on_corpse_explosion_button_pressed() -> void:
	corpse_explosion_button_pressed.emit("Corpse_Explosion")
