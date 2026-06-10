extends Area2D

@export var focus_damage: int = 10
@export var damage_cooldown: float = 1.0

var player_inside := false
var cooldown_remaining := 0.0


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
	if cooldown_remaining <= 0.0:
		apply_focus_damage()


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	player_inside = false


func apply_focus_damage() -> void:
	GameManager.change_focus(-focus_damage)
	cooldown_remaining = damage_cooldown
