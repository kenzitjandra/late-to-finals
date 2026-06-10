extends Area2D

# Moving Car Hazard - Approach Warning Version
#
# Concept:
# The car represents a vehicle approaching the crossing zone:
# - starts small/faded = safe
# - grows and fades in = warning
# - full size = dangerous hit window
# - fades out = safe again
#
# Damage only happens during the danger phase.
#
# grandma_event_car:
# 0 = normal car, always runs normally
# 1 = grandma-event car, can be paused when Grandma is helped

@export var focus_damage: int = 15
@export var damage_cooldown: float = 1.0

# 0 = normal/default car
# 1 = car is part of grandma crossing event and can be paused
@export var grandma_event_car: int = 0

# Timing
@export var approach_duration: float = 1.4
@export var danger_duration: float = 0.55
@export var fade_out_duration: float = 0.45
@export var cooldown_duration: float = 1.0

# Visual scale.
# X is larger than Y so the car looks wider.
@export var far_scale_x: float = 0.55
@export var far_scale_y: float = 0.30
@export var near_scale_x: float = 1.85
@export var near_scale_y: float = 0.95

# Visual opacity
@export var far_alpha: float = 0.15
@export var near_alpha: float = 1.0

# Warning blink speed
@export var warning_slow_blink_interval: float = 0.35
@export var warning_fast_blink_interval: float = 0.08

# Warning symbol position.
# More negative Y = higher above the car.
@export var warning_position: Vector2 = Vector2(-10, -125)

# Alternating timing.
# This staggers side-by-side cars so they do not all activate together.
@export var auto_alternate_timing: bool = true
@export var phase_offset: float = 0.0
@export var alternate_phase_gap: float = 1.2

enum CarPhase {
	APPROACH,
	DANGER,
	FADE_OUT,
	COOLDOWN
}

var current_phase: CarPhase = CarPhase.APPROACH
var phase_timer := 0.0

var player_inside := false
var damage_cooldown_remaining := 0.0

var visual_node: CanvasItem = null
var label_node: CanvasItem = null
var warning_label: Label = null

var blink_timer := 0.0
var warning_visible := true

var paused_by_grandma := false


func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

	_find_visual_nodes()
	_create_warning_label()

	current_phase = CarPhase.APPROACH
	phase_timer = _get_initial_phase_offset()

	_set_hazard_active(false)
	_apply_visual_state(far_scale_x, far_scale_y, far_alpha)
	_set_warning_visible(false)

	print(name, " approaching car hazard ready. grandma_event_car = ", grandma_event_car, ", initial offset = ", phase_timer)


func _process(delta: float) -> void:
	if paused_by_grandma:
		_process_paused_state()
		return

	if damage_cooldown_remaining > 0.0:
		damage_cooldown_remaining = maxf(damage_cooldown_remaining - delta, 0.0)

	phase_timer += delta

	match current_phase:
		CarPhase.APPROACH:
			_process_approach_phase(delta)

		CarPhase.DANGER:
			_process_danger_phase(delta)

		CarPhase.FADE_OUT:
			_process_fade_out_phase(delta)

		CarPhase.COOLDOWN:
			_process_cooldown_phase(delta)

	if player_inside and _is_danger_active() and damage_cooldown_remaining <= 0.0:
		apply_focus_damage()


func set_paused_by_grandma(value: bool) -> void:
	# Only grandma-event cars should pause.
	# Normal cars ignore this call.
	if grandma_event_car != 1:
		return

	paused_by_grandma = value

	if paused_by_grandma:
		_process_paused_state()
	else:
		# Restart safely after Grandma finishes crossing.
		current_phase = CarPhase.COOLDOWN
		phase_timer = 0.0
		_set_warning_visible(false)

	print(name, " paused_by_grandma = ", paused_by_grandma)


func _process_paused_state() -> void:
	_set_hazard_active(false)
	_apply_visual_state(far_scale_x, far_scale_y, 0.0)
	_set_warning_visible(false)


func _process_approach_phase(delta: float) -> void:
	_set_hazard_active(false)

	var progress := clampf(phase_timer / approach_duration, 0.0, 1.0)

	var current_scale_x := lerpf(far_scale_x, near_scale_x, progress)
	var current_scale_y := lerpf(far_scale_y, near_scale_y, progress)
	var current_alpha := lerpf(far_alpha, near_alpha, progress)

	_apply_visual_state(current_scale_x, current_scale_y, current_alpha)
	_process_warning_blink(delta, progress)

	if phase_timer >= approach_duration:
		_change_phase(CarPhase.DANGER)


func _process_danger_phase(delta: float) -> void:
	_set_hazard_active(true)
	_apply_visual_state(near_scale_x, near_scale_y, near_alpha)
	_process_warning_blink(delta, 1.0)

	if phase_timer >= danger_duration:
		_change_phase(CarPhase.FADE_OUT)


func _process_fade_out_phase(delta: float) -> void:
	_set_hazard_active(false)

	var progress := clampf(phase_timer / fade_out_duration, 0.0, 1.0)

	var current_scale_x := lerpf(near_scale_x, near_scale_x * 1.05, progress)
	var current_scale_y := lerpf(near_scale_y, near_scale_y * 1.05, progress)
	var current_alpha := lerpf(near_alpha, 0.0, progress)

	_apply_visual_state(current_scale_x, current_scale_y, current_alpha)
	_set_warning_visible(false)

	if phase_timer >= fade_out_duration:
		_change_phase(CarPhase.COOLDOWN)


func _process_cooldown_phase(_delta: float) -> void:
	_set_hazard_active(false)
	_apply_visual_state(far_scale_x, far_scale_y, 0.0)
	_set_warning_visible(false)

	if phase_timer >= cooldown_duration:
		_change_phase(CarPhase.APPROACH)


func _change_phase(new_phase: CarPhase) -> void:
	current_phase = new_phase
	phase_timer = 0.0
	blink_timer = 0.0
	warning_visible = true

	if new_phase == CarPhase.APPROACH:
		_set_warning_visible(true)
	elif new_phase == CarPhase.DANGER:
		_set_warning_visible(true)
	else:
		_set_warning_visible(false)


func _find_visual_nodes() -> void:
	visual_node = get_node_or_null("Visual") as CanvasItem
	label_node = get_node_or_null("Label") as CanvasItem

	if visual_node != null:
		return

	for child in get_children():
		if child is CanvasItem and not child is CollisionShape2D:
			visual_node = child
			break

	if visual_node == null:
		print("WARNING: ", name, " could not find a visual node.")


func _create_warning_label() -> void:
	warning_label = get_node_or_null("WarningLabel") as Label

	if warning_label == null:
		warning_label = Label.new()
		warning_label.name = "WarningLabel"
		add_child(warning_label)

	warning_label.text = "!"
	warning_label.position = warning_position
	warning_label.size = Vector2(48, 48)
	warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	warning_label.add_theme_font_size_override("font_size", 48)
	warning_label.modulate = Color(1.0, 0.05, 0.05, 1.0)


func _process_warning_blink(delta: float, danger_progress: float) -> void:
	if warning_label == null:
		return

	var blink_interval := lerpf(
		warning_slow_blink_interval,
		warning_fast_blink_interval,
		clampf(danger_progress, 0.0, 1.0)
	)

	blink_timer += delta

	if blink_timer >= blink_interval:
		blink_timer = 0.0
		warning_visible = not warning_visible
		_set_warning_visible(warning_visible)


func _set_warning_visible(value: bool) -> void:
	if warning_label != null:
		warning_label.visible = value


func _apply_visual_state(scale_x: float, scale_y: float, alpha_value: float) -> void:
	scale = Vector2(scale_x, scale_y)

	var new_modulate := Color(1.0, 1.0, 1.0, alpha_value)

	if visual_node != null:
		visual_node.modulate = new_modulate

	if label_node != null:
		label_node.modulate = new_modulate


func _set_hazard_active(_value: bool) -> void:
	# Keep monitoring on so the script knows if the player is inside.
	# Damage is controlled by _is_danger_active().
	monitoring = true
	monitorable = true


func _is_danger_active() -> bool:
	return current_phase == CarPhase.DANGER and not paused_by_grandma


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	player_inside = true

	if _is_danger_active() and damage_cooldown_remaining <= 0.0:
		apply_focus_damage()


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	player_inside = false


func apply_focus_damage() -> void:
	GameManager.change_focus(-focus_damage)
	damage_cooldown_remaining = damage_cooldown


func _get_initial_phase_offset() -> float:
	if not auto_alternate_timing:
		return phase_offset

	var number := _get_number_from_name(name)

	if number > 0:
		if number % 2 == 0:
			return alternate_phase_gap
		else:
			return 0.0

	var parent_node := get_parent()
	if parent_node == null:
		return phase_offset

	var car_index := 0

	for child in parent_node.get_children():
		if child == self:
			break

		if child is Area2D and String(child.name).contains("Car"):
			car_index += 1

	if car_index % 2 == 0:
		return 0.0
	else:
		return alternate_phase_gap


func _get_number_from_name(node_name: String) -> int:
	var digits := ""

	for i in range(node_name.length() - 1, -1, -1):
		var character := node_name[i]

		if character.is_valid_int():
			digits = character + digits
		elif digits != "":
			break

	if digits == "":
		return -1

	return int(digits)