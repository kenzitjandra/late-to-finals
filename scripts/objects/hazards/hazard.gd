extends Area2D

@export var focus_damage: int = 10
@export var damage_cooldown: float = 1.0

# If false, hazard is always active.
# If true, hazard alternates active/off.
@export var flashing_enabled: bool = false
@export var active_duration: float = 1.2
@export var inactive_duration: float = 1.2

@export var active_modulate := Color(1.0, 1.0, 1.0, 1.0)
@export var inactive_modulate := Color(0.35, 0.35, 0.35, 0.45)

var player_inside := false
var cooldown_remaining := 0.0
var is_active := true
var phase_remaining := 0.0

var visual_node: CanvasItem = null
var label_node: CanvasItem = null


func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

	_find_visual_nodes()

	is_active = true
	phase_remaining = active_duration

	_update_active_state()
	print(name, " hazard ready. flashing_enabled = ", flashing_enabled)


func _process(delta: float) -> void:
	if flashing_enabled:
		phase_remaining -= delta

		if phase_remaining <= 0.0:
			is_active = not is_active
			phase_remaining = active_duration if is_active else inactive_duration
			_update_active_state()

	if cooldown_remaining > 0.0:
		cooldown_remaining = maxf(cooldown_remaining - delta, 0.0)

	# Damage only while player is inside AND hazard is active.
	if player_inside and is_active and cooldown_remaining <= 0.0:
		apply_focus_damage()


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	player_inside = true

	# Important:
	# If wiring is currently off, entering the hitbox should NOT damage the player.
	if is_active and cooldown_remaining <= 0.0:
		apply_focus_damage()


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	player_inside = false


func apply_focus_damage() -> void:
	GameManager.change_focus(-focus_damage)
	cooldown_remaining = damage_cooldown


func _find_visual_nodes() -> void:
	# Case 1:
	# Script is on root ExposedWiring Area2D:
	# ExposedWiring
	# ├── Visual
	# └── Label
	visual_node = get_node_or_null("Visual") as CanvasItem
	label_node = get_node_or_null("Label") as CanvasItem

	if visual_node != null:
		return

	# Case 2:
	# Script is on child MechanicArea:
	# ExposedWiring
	# ├── Visual
	# ├── Label
	# └── MechanicArea
	var parent_node := get_parent()

	if parent_node != null:
		visual_node = parent_node.get_node_or_null("Visual") as CanvasItem
		label_node = parent_node.get_node_or_null("Label") as CanvasItem

	if visual_node == null:
		print("WARNING: ", name, " could not find Visual node for blinking.")


func _update_active_state() -> void:
	# If flashing is disabled, keep hazard fully visible and active.
	if not flashing_enabled:
		is_active = true
		monitoring = true
		_update_visual(active_modulate)
		return

	# Keep monitoring on. We still need to know if the player is inside.
	# The damage check decides whether to hurt the player.
	monitoring = true

	if is_active:
		_update_visual(active_modulate)
	else:
		_update_visual(inactive_modulate)


func _update_visual(new_modulate: Color) -> void:
	if visual_node != null:
		visual_node.modulate = new_modulate

	if label_node != null:
		label_node.modulate = new_modulate
