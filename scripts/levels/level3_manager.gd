extends Node

# Level 3 Manager - Final Hall Sprint
# Handles:
# - HUD objective
# - player camera setup
# - fake exit respawn
# - real exam hall exit
# - simple final ending print

@onready var player: CharacterBody2D = get_node_or_null("Player")
@onready var hud: Node = get_node_or_null("HUD")
@onready var exam_hall_trigger: Area2D = get_node_or_null("Exits/ExamHallExit")
@onready var fake_exit_trigger: Area2D = get_node_or_null("Exits/FakeExit")

var start_position := Vector2(180, 1256)


func _ready() -> void:
	print("Level 3: Final Hall Sprint - Starting setup")

	if player == null:
		push_error("Level 3 setup error: Player node not found.")
		return

	start_position = player.global_position
	player.last_safe_position = start_position

	_setup_game_manager_state()
	_setup_hud_objective()
	_setup_player_camera()
	_setup_exit_triggers()

	# Run again after one frame because HUD/GameManager may overwrite text during ready.
	call_deferred("_late_setup")

	print("Level 3: Final Hall Sprint - Ready")


func _late_setup() -> void:
	_setup_hud_objective()
	_setup_player_camera()


func _setup_game_manager_state() -> void:
	if Engine.has_singleton("GameManager"):
		return

	# GameManager is likely an autoload, so direct access is expected in this project.
	if "level_state" in GameManager:
		GameManager.level_state = GameManager.LEVEL_STATE_PLAYING

	if "current_objective" in GameManager:
		GameManager.current_objective = "Enter the Exam Hall"


func _setup_hud_objective() -> void:
	if hud == null:
		print("WARNING: HUD node not found.")
		return

	# Preferred: update through HUD method if it exists.
	if hud.has_method("set_objective"):
		hud.set_objective("Enter the Exam Hall")
		return

	# Fallback: update common label path directly.
	var objective_label := hud.get_node_or_null("VBoxContainer/ObjectiveLabel")
	if objective_label != null:
		objective_label.text = "Objective: Enter the Exam Hall"
		return

	print("WARNING: Could not find HUD objective label.")


func _setup_player_camera() -> void:
	if player == null:
		return

	# Disable overview/static cameras so they do not steal the view.
	var overview_camera := get_node_or_null("LevelOverviewCamera")
	if overview_camera != null and overview_camera is Camera2D:
		overview_camera.enabled = false

	# Find existing player camera.
	var player_camera: Camera2D = null

	for child in player.get_children():
		if child is Camera2D:
			player_camera = child
			break

	# Create one if the Player scene does not already have a camera.
	if player_camera == null:
		player_camera = Camera2D.new()
		player_camera.name = "Level3PlayerCamera"
		player.add_child(player_camera)
		print("Created new Camera2D under Player.")

	player_camera.position = Vector2.ZERO
	player_camera.enabled = true
	player_camera.make_current()

	# These limits match the blockout map size.
	player_camera.limit_left = 0
	player_camera.limit_top = 0
	player_camera.limit_right = 5800
	player_camera.limit_bottom = 1500

	# Keep it simple and stable for demo.
	player_camera.position_smoothing_enabled = false
	player_camera.zoom = Vector2(1, 1)

	print("Player camera enabled and set current.")


func _setup_exit_triggers() -> void:
	if exam_hall_trigger != null:
		exam_hall_trigger.monitoring = true
		exam_hall_trigger.monitorable = true

		if not exam_hall_trigger.body_entered.is_connected(_on_exam_hall_entered):
			exam_hall_trigger.body_entered.connect(_on_exam_hall_entered)

		print("ExamHallExit trigger connected.")
	else:
		print("ERROR: ExamHallExit trigger not found at Exits/ExamHallExit.")

	if fake_exit_trigger != null:
		fake_exit_trigger.monitoring = true
		fake_exit_trigger.monitorable = true

		if not fake_exit_trigger.body_entered.is_connected(_on_fake_exit_entered):
			fake_exit_trigger.body_entered.connect(_on_fake_exit_entered)

		print("FakeExit trigger connected.")
	else:
		print("WARNING: FakeExit trigger not found at Exits/FakeExit.")


func _on_fake_exit_entered(body: Node2D) -> void:
	print("Fake exit touched by: ", body.name)

	if not _is_player(body):
		return

	print("Wrong room! Returning to start.")

	if "change_focus" in GameManager:
		GameManager.change_focus(-5)

	body.global_position = start_position

	if "velocity" in body:
		body.velocity = Vector2.ZERO

	if body.has_method("set_slippery_movement"):
		body.set_slippery_movement(false)

	if body.has_method("set_inside_fall_zone"):
		body.set_inside_fall_zone(false)


func _on_exam_hall_entered(body: Node2D) -> void:
	print("Exam hall exit touched by: ", body.name)

	if not _is_player(body):
		return

	print("Level 3 Complete! Reached the Exam Hall.")
	print("---")
	print("Final Stats:")
	print("  Time remaining: ", GameManager.time_remaining)
	print("  Focus: ", GameManager.focus)
	print("  Notes collected: ", GameManager.notes_collected)
	print("  Coffee: ", GameManager.coffee_collected)
	print("---")

	calculate_ending()


func _is_player(body: Node) -> bool:
	if body == player:
		return true

	if body.name == "Player":
		return true

	if body.is_in_group("player"):
		return true

	return false


func calculate_ending() -> void:
	var ending := "UNKNOWN"

	if GameManager.time_remaining <= 0:
		ending = "MISSED EXAM"
	elif GameManager.focus < 30 or GameManager.notes_collected < 2:
		ending = "ARRIVED UNPREPARED"
	elif GameManager.focus < 50 or GameManager.notes_collected < 4:
		ending = "BARELY PASSED"
	elif GameManager.focus >= 50 and GameManager.notes_collected >= 4:
		if GameManager.time_remaining > 30:
			ending = "PERFECT STUDENT"
		else:
			ending = "PASSED"

	print("ENDING: ", ending)