# Level 1 movement-control hazard: slippery floor with small Focus damage.
extends Area2D

@export var focus_damage: int = 5
@export var damage_cooldown: float = 1.0

var player_inside := false
var cooldown_remaining := 0.0
var current_player: Node2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	if cooldown_remaining > 0.0:
		cooldown_remaining = maxf(cooldown_remaining - delta, 0.0)

	if player_inside and cooldown_remaining <= 0.0:
		apply_focus_damage()


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	player_inside = true
	current_player = body
	if body.has_method("set_slippery_movement"):
		body.set_slippery_movement(true)

	if cooldown_remaining <= 0.0:
		apply_focus_damage()


func _on_body_exited(body: Node2D) -> void:
	if body != current_player:
		return

	player_inside = false
	current_player = null
	if body.has_method("set_slippery_movement"):
		body.set_slippery_movement(false)


func apply_focus_damage() -> void:
	GameManager.change_focus(-focus_damage)
	cooldown_remaining = damage_cooldown
