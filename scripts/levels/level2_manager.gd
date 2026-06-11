extends Node

# Level 2 Manager - Campus Rush
# Handles:
# - Level 2 objective setup
# - player camera setup
# - faculty building exit trigger
# - transition to Level 3

@onready var player: CharacterBody2D = get_node_or_null("Player")
@onready var hud: Node = get_node_or_null("HUD")

var faculty_exit_trigger: Area2D = null
var start_position := Vector2(160, 820)
var level_finished := false


func _ready() -> void:
	print("Level 2: Campus Rush - Starting setup")

	if player == null:
		push_error("Level 2 setup error: Player node not found.")
		return

	start_position = player.global_position
	player.last_safe_position = start_position

	_find_exit_trigger()
	_setup_game_manager_state()
	_setup_hud_objective()
	_setup_player_camera()
	_setup_exit_trigger()

	call_deferred("_late_setup")

	print("Level 2: Campus Rush - Ready")


func _late_setup() -> void:
	_find_exit_trigger()
	_setup_game_manager_state()
	_setup_hud_objective()
	_setup_player_camera()
	_setup_exit_trigger()


func _find_exit_trigger() -> void:
	faculty_exit_trigger = get_node_or_null("Exits/FacultyBuildingExit") as Area2D

	if faculty_exit_trigger == null:
		faculty_exit_trigger = get_node_or_null("FacultyBuildingExit") as Area2D

	if faculty_exit_trigger == null:
		print("ERROR: FacultyBuildingExit trigger not found.")
	else:
		print("FacultyBuildingExit found at: ", faculty_exit_trigger.get_path())


func _setup_game_manager_state() -> void:
	if GameManager.has_method("set_level_display_name"):
		GameManager.set_level_display_name("Level 2")

	GameManager.level_state = GameManager.LEVEL_STATE_PLAYING
	GameManager.has_student_id = true

	if GameManager.time_remaining <= 0.0:
		GameManager.time_remaining = 180.0

	if GameManager.has_method("set_objective"):
		GameManager.set_objective("Reach the Faculty Building")


func _setup_hud_objective() -> void:
	if GameManager.has_method("set_objective"):
		GameManager.set_objective("Reach the Faculty Building")

	if hud == null:
		print("WARNING: HUD node not found.")
		return

	var objective_label := hud.get_node_or_null("VBoxContainer/ObjectiveLabel")
	if objective_label != null:
		objective_label.text = "Objective: Reach the Faculty Building"


func _setup_player_camera() -> void:
	if player == null:
		return

	var overview_camera := get_node_or_null("LevelOverviewCamera")
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
	player_camera.zoom = Vector2(0.75, 0.75)
	player_camera.offset = Vector2(0, -120)
	player_camera.limit_left = 0
	player_camera.limit_top = -1250
	player_camera.limit_right = 7800
	player_camera.limit_bottom = 400
	player_camera.position_smoothing_enabled = false

	print("Level 2 player camera enabled.")


func _setup_exit_trigger() -> void:
	if faculty_exit_trigger == null:
		print("ERROR: Cannot connect FacultyBuildingExit because trigger is null.")
		return

	faculty_exit_trigger.monitoring = true
	faculty_exit_trigger.monitorable = true

	if not faculty_exit_trigger.body_entered.is_connected(_on_faculty_building_entered):
		faculty_exit_trigger.body_entered.connect(_on_faculty_building_entered)

	print("FacultyBuildingExit trigger connected.")


func _on_faculty_building_entered(body: Node2D) -> void:
	print("Faculty building exit touched by: ", body.name)

	if level_finished:
		return

	if not _is_player(body):
		return

	if GameManager.has_method("is_level_active"):
		if not GameManager.is_level_active():
			return

	level_finished = true

	print("Level 2 Complete! Loading Level 3.")

	if GameManager.has_method("go_to_level_3_from_level_2"):
		GameManager.go_to_level_3_from_level_2()
	else:
		GameManager.level_state = GameManager.LEVEL_STATE_PLAYING
		get_tree().change_scene_to_file.call_deferred("res://scenes/levels/Level3_FinalHallSprint.tscn")


func _is_player(body: Node) -> bool:
	if body == player:
		return true

	if body.name == "Player":
		return true

	if body.is_in_group("player"):
		return true

	return false