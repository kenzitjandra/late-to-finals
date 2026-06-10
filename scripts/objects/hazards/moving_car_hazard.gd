extends Area2D

@export var speed: float = 210.0
@export var move_distance: float = 150.0
@export var focus_damage: int = 15
@export var damage_cooldown: float = 1.0
@export var start_direction: float = 1.0

var start_y := 0.0
var direction := 1.0
var player_inside := false
var cooldown_remaining := 0.0


func _ready() -> void:
	start_y = position.y
	direction = signf(start_direction)
	if direction == 0.0:
		direction = 1.0
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	position.y += direction * speed * delta

	if position.y >= start_y + move_distance:
		position.y = start_y + move_distance
		direction = -1.0
	elif position.y <= start_y - move_distance:
		position.y = start_y - move_distance
		direction = 1.0

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
