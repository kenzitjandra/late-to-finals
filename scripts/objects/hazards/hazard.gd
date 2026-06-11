extends Area2D

@export var focus_damage: int = 10
@export var damage_cooldown: float = 1.0

# Flashing / electricity settings
@export var flashing_enabled: bool = true
@export var active_duration: float = 1.0
@export var inactive_duration: float = 1.0

# Visual effect
@export var active_alpha: float = 1.0
@export var inactive_alpha: float = 0.25

# Fake glow effect using color brightness.
# Works even without adding Light2D.
@export var active_color: Color = Color(1.6, 1.6, 1.0, 1.0)
@export var inactive_color: Color = Color(0.4, 0.4, 0.4, 0.25)

var cooldown_remaining := 0.0
var flash_timer := 0.0
var is_active := true

var visual_nodes: Array[CanvasItem] = []
var player_inside: Node2D = null


func _ready() -> void:
	_find_visual_nodes()

	monitoring = true
	monitorable = true

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

	if flashing_enabled:
		is_active = true
		flash_timer = active_duration
	else:
		is_active = true

	_apply_visual_state()

	print(name, " hazard ready. flashing_enabled = ", flashing_enabled)


func _process(delta: float) -> void:
	if cooldown_remaining > 0.0:
		cooldown_remaining = maxf(cooldown_remaining - delta, 0.0)

	if flashing_enabled:
		_update_flashing(delta)

	if player_inside != null and is_active and cooldown_remaining <= 0.0:
		_damage_player(player_inside)


func _update_flashing(delta: float) -> void:
	flash_timer -= delta

	if flash_timer > 0.0:
		return

	is_active = not is_active

	if is_active:
		flash_timer = active_duration
	else:
		flash_timer = inactive_duration

	_apply_visual_state()


func _apply_visual_state() -> void:
	for visual in visual_nodes:
		if visual == null:
			continue

		if is_active:
			visual.visible = true
			visual.modulate = active_color
		else:
			visual.visible = true
			visual.modulate = inactive_color


func _on_body_entered(body: Node2D) -> void:
	if not _is_player(body):
		return

	player_inside = body

	if is_active and cooldown_remaining <= 0.0:
		_damage_player(body)


func _on_body_exited(body: Node2D) -> void:
	if body == player_inside:
		player_inside = null


func _damage_player(body: Node2D) -> void:
	cooldown_remaining = damage_cooldown

	if GameManager.has_method("change_focus"):
		GameManager.change_focus(-focus_damage)

	print(name, " damaged player. Focus -", focus_damage)


func _is_player(body: Node) -> bool:
	if body.name == "Player":
		return true

	if body.is_in_group("player"):
		return true

	return false


func _find_visual_nodes() -> void:
	visual_nodes.clear()

	# Common direct visual names.
	var visual := get_node_or_null("Visual") as CanvasItem
	if visual != null:
		visual_nodes.append(visual)

	var sprite := get_node_or_null("Sprite2D") as CanvasItem
	if sprite != null:
		visual_nodes.append(sprite)

	var label := get_node_or_null("Label") as CanvasItem
	if label != null:
		visual_nodes.append(label)

	# If this script is on a child Area2D named MechanicArea,
	# visuals may be on the parent ExposedWiring node.
	var parent_node := get_parent()
	if parent_node != null:
		var parent_visual := parent_node.get_node_or_null("Visual") as CanvasItem
		if parent_visual != null:
			visual_nodes.append(parent_visual)

		var parent_sprite := parent_node.get_node_or_null("Sprite2D") as CanvasItem
		if parent_sprite != null:
			visual_nodes.append(parent_sprite)

		var parent_label := parent_node.get_node_or_null("Label") as CanvasItem
		if parent_label != null:
			visual_nodes.append(parent_label)

	if visual_nodes.is_empty():
		print("WARNING: ", name, " hazard has no visual nodes found.")
