extends Area2D

@export var focus_damage: int = 10
@export var damage_cooldown: float = 1.0
@export var flashing_enabled := false
@export var active_duration: float = 1.2
@export var inactive_duration: float = 1.2
@export var active_modulate := Color(1.4, 0.65, 0.35, 1.0)
@export var inactive_modulate := Color(0.35, 0.35, 0.35, 0.65)

var player_inside := false
var cooldown_remaining := 0.0
var is_active := true
var phase_remaining := 0.0
var visual_parent: CanvasItem
var original_modulate := Color.WHITE


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	visual_parent = get_parent() as CanvasItem
	if visual_parent:
		original_modulate = visual_parent.modulate
	phase_remaining = active_duration
	_update_visual_state()


func _process(delta: float) -> void:
	if flashing_enabled:
		phase_remaining -= delta
		if phase_remaining <= 0.0:
			is_active = not is_active
			phase_remaining = active_duration if is_active else inactive_duration
			_update_visual_state()

	if cooldown_remaining > 0.0:
		cooldown_remaining = maxf(cooldown_remaining - delta, 0.0)

	if player_inside and is_active and cooldown_remaining <= 0.0:
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


func _update_visual_state() -> void:
	if not flashing_enabled or visual_parent == null:
		return

	visual_parent.modulate = active_modulate if is_active else inactive_modulate
