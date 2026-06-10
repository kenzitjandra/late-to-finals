extends Area2D

# Grandma Road Interaction
#
# Help Grandma:
# - lose 45 seconds
# - pause only grandma-event cars
# - grandma crosses to the other side
# - gain 3 secret notes
# - unlock/open the locked door
#
# Ignore Grandma:
# - save time
# - gain nothing
# - door stays locked

@export var help_time_cost: float = 45.0
@export var reward_notes: int = 3

# How fast Grandma moves while crossing.
@export var grandma_cross_speed: float = 90.0

# Where Grandma should move to after the player helps her.
# Set this manually in the Inspector.
# Example: if Grandma starts at Vector2(3500, -70), set this to Vector2(4050, -70)
@export var cross_target_position: Vector2 = Vector2.ZERO

# Optional. Drag the LockedDoor node here in the Inspector.
# If this is empty, the script searches the whole scene for a door.
@export var locked_door_path: NodePath

@export var prompt_text := "Grandma: Can you help me cross?\nE = Help (-45s, +3 notes, get key)\nQ = Ignore"
@export var crossing_text := "Grandma is crossing... Cars stopped."
@export var helped_text := "Grandma: Thank you! I used to be a lecturer.\nHere are my secret notes and the overpass key!"
@export var ignored_text := "Grandma: It's okay. Be careful crossing!"

var player_inside := false
var decision_finished := false
var is_crossing := false
var message_timer := 0.0

var prompt_label: Label = null
var message_label: Label = null
var visual_node: CanvasItem = null


func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

	_find_or_create_visuals()
	_show_prompt(false)
	_show_message("", false)

	# If you forget to set a target, Grandma will move 400px to the right by default.
	if cross_target_position == Vector2.ZERO:
		cross_target_position = global_position + Vector2(400, 0)

	print("Grandma interaction ready.")
	print("Grandma cross target: ", cross_target_position)
	_debug_find_door()


func _process(delta: float) -> void:
	if message_timer > 0.0:
		message_timer = maxf(message_timer - delta, 0.0)
		if message_timer <= 0.0 and not is_crossing:
			_show_message("", false)

	if is_crossing:
		_move_grandma_across(delta)
		return

	if decision_finished:
		return

	if not player_inside:
		return

	if Input.is_action_just_pressed("interact"):
		_help_grandma()
	elif Input.is_key_pressed(KEY_Q):
		_ignore_grandma()


func _on_body_entered(body: Node2D) -> void:
	if not _is_player(body):
		return

	player_inside = true

	if not decision_finished:
		_show_prompt(true)


func _on_body_exited(body: Node2D) -> void:
	if not _is_player(body):
		return

	player_inside = false
	_show_prompt(false)


func _help_grandma() -> void:
	if decision_finished:
		return

	decision_finished = true
	_show_prompt(false)

	# Lose 45 seconds immediately when choosing to help.
	if "time_remaining" in GameManager:
		GameManager.time_remaining = maxf(GameManager.time_remaining - help_time_cost, 0.0)

	# Stop only cars marked grandma_event_car = 1.
	_set_grandma_event_cars_paused(true)

	_show_message(crossing_text, true)
	message_timer = 999.0

	is_crossing = true

	print("Grandma help accepted: -", help_time_cost, " seconds. Grandma crossing started.")


func _move_grandma_across(delta: float) -> void:
	global_position = global_position.move_toward(cross_target_position, grandma_cross_speed * delta)

	if global_position.distance_to(cross_target_position) <= 2.0:
		global_position = cross_target_position
		is_crossing = false
		_finish_helping_grandma()


func _finish_helping_grandma() -> void:
	# Gain 3 secret notes after Grandma reaches the other side.
	for i in range(reward_notes):
		if GameManager.has_method("collect_study_note"):
			GameManager.collect_study_note()
		elif "notes_collected" in GameManager:
			GameManager.notes_collected += 1

	# Store key flag if GameManager already supports it.
	if "has_overpass_key" in GameManager:
		GameManager.has_overpass_key = true

	# Unlock the door after helping Grandma.
	_unlock_locked_door()

	# Resume grandma-event cars after Grandma has crossed.
	_set_grandma_event_cars_paused(false)

	_show_message(helped_text, true)
	message_timer = 5.0

	if visual_node != null:
		visual_node.modulate = Color(0.6, 0.6, 0.6, 0.45)

	print("Grandma crossed safely: +", reward_notes, " notes, key acquired, door unlock attempted.")


func _ignore_grandma() -> void:
	if decision_finished:
		return

	decision_finished = true
	_show_prompt(false)

	_show_message(ignored_text, true)
	message_timer = 3.5

	if visual_node != null:
		visual_node.modulate = Color(0.6, 0.6, 0.6, 0.45)

	print("Grandma ignored: no time loss, no notes, no key, door stays locked.")


func _unlock_locked_door() -> void:
	var locked_door := _get_locked_door()

	if locked_door == null:
		print("ERROR: Grandma could not find any LockedDoor node to unlock.")
		return

	print("Grandma found door: ", locked_door.get_path())

	if locked_door.has_method("open"):
		locked_door.open()
		print("SUCCESS: Locked door opened by grandma key.")
	else:
		print("ERROR: Found door, but it has no open() method: ", locked_door.name)


func _get_locked_door() -> Node:
	# 1. Use manually assigned NodePath first.
	if locked_door_path != NodePath():
		var selected_door := get_node_or_null(locked_door_path)
		if selected_door != null:
			return selected_door
		else:
			print("WARNING: locked_door_path was assigned but did not resolve: ", locked_door_path)

	var root := get_tree().current_scene
	if root == null:
		return null

	# 2. Prefer exact name LockedDoor.
	var exact := _find_node_by_name_recursive(root, "LockedDoor")
	if exact != null:
		return exact

	# 3. Fallback: find any node with Door in name and open() method.
	var any_door := _find_any_openable_door_recursive(root)
	if any_door != null:
		return any_door

	return null


func _find_node_by_name_recursive(node: Node, target_name: String) -> Node:
	if node.name == target_name:
		return node

	for child in node.get_children():
		var found := _find_node_by_name_recursive(child, target_name)
		if found != null:
			return found

	return null


func _find_any_openable_door_recursive(node: Node) -> Node:
	if String(node.name).contains("Door") and node.has_method("open"):
		return node

	for child in node.get_children():
		var found := _find_any_openable_door_recursive(child)
		if found != null:
			return found

	return null


func _debug_find_door() -> void:
	var door := _get_locked_door()
	if door == null:
		print("Grandma debug: No door found yet.")
	else:
		print("Grandma debug: Door found at ", door.get_path())


func _set_grandma_event_cars_paused(value: bool) -> void:
	var root := get_tree().current_scene
	if root == null:
		return

	_set_grandma_event_cars_paused_recursive(root, value)


func _set_grandma_event_cars_paused_recursive(node: Node, value: bool) -> void:
	if node.has_method("set_paused_by_grandma"):
		node.set_paused_by_grandma(value)

	for child in node.get_children():
		_set_grandma_event_cars_paused_recursive(child, value)


func _find_or_create_visuals() -> void:
	visual_node = get_node_or_null("Visual") as CanvasItem

	prompt_label = get_node_or_null("PromptLabel") as Label
	if prompt_label == null:
		prompt_label = Label.new()
		prompt_label.name = "PromptLabel"
		add_child(prompt_label)

	prompt_label.position = Vector2(-250, -165)
	prompt_label.size = Vector2(500, 110)
	prompt_label.text = prompt_text
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	prompt_label.add_theme_font_size_override("font_size", 18)

	message_label = get_node_or_null("MessageLabel") as Label
	if message_label == null:
		message_label = Label.new()
		message_label.name = "MessageLabel"
		add_child(message_label)

	message_label.position = Vector2(-260, -95)
	message_label.size = Vector2(520, 90)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 18)


func _show_prompt(value: bool) -> void:
	if prompt_label != null:
		prompt_label.visible = value


func _show_message(text: String, value: bool) -> void:
	if message_label != null:
		message_label.text = text
		message_label.visible = value


func _is_player(body: Node) -> bool:
	if body.name == "Player":
		return true

	if body.is_in_group("player"):
		return true

	return false