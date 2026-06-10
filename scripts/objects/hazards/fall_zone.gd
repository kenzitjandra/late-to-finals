extends Area2D

@export var focus_damage: int = 10

var respawning := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if respawning or not body.is_in_group("player") or not GameManager.is_level_active():
		return

	respawning = true
	if body.has_method("set_inside_fall_zone"):
		body.set_inside_fall_zone(true)

	GameManager.change_focus(-focus_damage)
	if body.has_method("respawn_to_last_safe_position"):
		body.respawn_to_last_safe_position()

	respawning = false


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("set_inside_fall_zone"):
		body.set_inside_fall_zone(false)
