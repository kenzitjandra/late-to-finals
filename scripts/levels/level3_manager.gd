extends Node

# Level 3 Manager - Final Hall Sprint
# Handles:
# - Level 3 objective setup
# - player camera setup
# - exam hall trigger
# - final performance ending
# - HUD result panel through GameManager

@onready var player: CharacterBody2D = find_child("Player", true, false) as CharacterBody2D
@onready var hud: Node = find_child("HUD", true, false)

var exam_hall_trigger: Area2D = null
var level_finished := false


func _ready() -> void:
	print("Level 3: Final Hall Sprint - Starting setup")

	if player == null:
		push_error("Level 3 setup error: Player node not found.")
		return

	_find_exam_hall_trigger()
	_setup_game_manager_state()
	_setup_hud_objective()
	_setup_player_camera()
	_setup_exam_hall_trigger()

	call_deferred("_late_setup")

	print("Level 3: Final Hall Sprint - Ready")


func _late_setup() -> void:
	_find_exam_hall_trigger()
	_setup_game_manager_state()
	_setup_hud_objective()
	_setup_player_camera()
	_setup_exam_hall_trigger()


func _find_exam_hall_trigger() -> void:
	exam_hall_trigger = null

	# Direct paths first.
	exam_hall_trigger = get_node_or_null("ExamHallExit") as Area2D

	if exam_hall_trigger == null:
		exam_hall_trigger = get_node_or_null("ExamHallTrigger") as Area2D

	if exam_hall_trigger == null:
		exam_hall_trigger = get_node_or_null("Hallway/ExamHallExit") as Area2D

	# Recursive search through the whole Level 3 scene.
	if exam_hall_trigger == null:
		exam_hall_trigger = find_child("ExamHallExit", true, false) as Area2D

	if exam_hall_trigger == null:
		exam_hall_trigger = find_child("ExamHallTrigger", true, false) as Area2D

	if exam_hall_trigger == null:
		print("ERROR: Exam hall trigger not found. Expected ExamHallExit or ExamHallTrigger somewhere in the scene tree.")
	else:
		print("Exam hall trigger found at: ", exam_hall_trigger.get_path())


func _setup_game_manager_state() -> void:
	if GameManager.has_method("set_level_display_name"):
		GameManager.set_level_display_name("Level 3")

	GameManager.level_state = GameManager.LEVEL_STATE_PLAYING
	GameManager.has_student_id = true

	if GameManager.time_remaining <= 0.0:
		GameManager.time_remaining = 180.0

	if GameManager.has_method("set_objective"):
		GameManager.set_objective("Enter the Exam Hall")
	else:
		GameManager.current_objective = "Enter the Exam Hall"


func _setup_hud_objective() -> void:
	if GameManager.has_method("set_objective"):
		GameManager.set_objective("Enter the Exam Hall")
	else:
		GameManager.current_objective = "Enter the Exam Hall"

	if hud == null:
		print("WARNING: HUD node not found.")
		return

	var objective_label := hud.get_node_or_null("VBoxContainer/ObjectiveLabel")
	if objective_label != null:
		objective_label.text = "Objective: Enter the Exam Hall"


func _setup_player_camera() -> void:
	if player == null:
		return

	var overview_camera := find_child("LevelOverviewCamera", true, false)
	if overview_camera != null and overview_camera is Camera2D:
		overview_camera.enabled = false

	var player_camera: Camera2D = null

	for child in player.get_children():
		if child is Camera2D:
			player_camera = child
			break

	if player_camera == null:
		player_camera = Camera2D.new()
		player_camera.name = "Camera2D"
		player.add_child(player_camera)
		print("Created new Camera2D under Player.")

	player_camera.enabled = true
	player_camera.make_current()
	player_camera.zoom = Vector2(1, 1)
	player_camera.limit_left = 0
	player_camera.limit_top = 0
	player_camera.limit_right = 5800
	player_camera.limit_bottom = 1500
	player_camera.position_smoothing_enabled = false

	print("Level 3 player camera enabled.")


func _setup_exam_hall_trigger() -> void:
	if exam_hall_trigger == null:
		print("ERROR: Cannot connect exam hall trigger because it is null.")
		return

	exam_hall_trigger.monitoring = true
	exam_hall_trigger.monitorable = true

	if not exam_hall_trigger.body_entered.is_connected(_on_exam_hall_entered):
		exam_hall_trigger.body_entered.connect(_on_exam_hall_entered)

	print("Exam hall trigger connected.")


func _on_exam_hall_entered(body: Node2D) -> void:
	print("Exam hall trigger touched by: ", body.name)

	if level_finished:
		return

	if not _is_player(body):
		return

	if GameManager.has_method("is_level_active"):
		if not GameManager.is_level_active():
			return

	level_finished = true

	print("Level 3 Complete! Reached the Exam Hall.")
	print("---")
	print("Final Stats:")
	print("  Time remaining: ", GameManager.time_remaining)
	print("  Focus: ", GameManager.focus)
	print("  Notes collected: ", GameManager.notes_collected)
	print("  Coffee collected: ", GameManager.coffee_collected)
	print("  Student ID: ", GameManager.has_student_id)
	print("---")

	_calculate_and_store_ending()

	if GameManager.has_method("complete_current_level"):
		GameManager.complete_current_level("Level 3")
	else:
		GameManager.complete_level_1()


func _calculate_and_store_ending() -> void:
	var ending_title := "UNKNOWN"
	var ending_description := ""

	if GameManager.time_remaining <= 0:
		ending_title = "MISSED EXAM"
		ending_description = "You reached too late and missed the final exam."

	elif GameManager.focus < 30 or GameManager.notes_collected < 2:
		ending_title = "ARRIVED UNPREPARED"
		ending_description = "You reached the exam hall, but low focus or too few notes left you unprepared."

	elif GameManager.focus < 50 or GameManager.notes_collected < 4:
		ending_title = "BARELY PASSED"
		ending_description = "You made it to the exam and survived the chaos, but your preparation was weak."

	elif GameManager.focus >= 50 and GameManager.notes_collected >= 4:
		if GameManager.time_remaining > 30:
			ending_title = "PERFECT STUDENT"
			ending_description = "You arrived on time, stayed focused, collected enough notes, and were fully prepared."
		else:
			ending_title = "PASSED"
			ending_description = "You reached the exam hall prepared enough to pass, but with little time to spare."

	if GameManager.has_method("set_final_ending"):
		GameManager.set_final_ending(ending_title, ending_description)

	print("ENDING: ", ending_title)
	print("ENDING DESCRIPTION: ", ending_description)


func _is_player(body: Node) -> bool:
	if body == player:
		return true

	if body.name == "Player":
		return true

	if body.is_in_group("player"):
		return true

	return false