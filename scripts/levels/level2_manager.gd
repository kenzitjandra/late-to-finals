extends Node

# Level 2 Manager - Campus Rush
# Merged version:
# - Keeps Level 2 objective setup
# - Keeps Student ID = Yes for Level 2
# - Keeps FacultyBuildingExit completion trigger
# - Keeps friend’s polished Level 2 camera settings

const CAMERA_LIMIT_LEFT := 0
const CAMERA_LIMIT_TOP := -1250
const CAMERA_LIMIT_RIGHT := 7800
const CAMERA_LIMIT_BOTTOM := 400

@onready var player: CharacterBody2D = get_node_or_null("Player")
@onready var hud: Node = get_node_or_null("HUD")
@onready var faculty_exit_trigger: Area2D = get_node_or_null("Exits/FacultyBuildingExit")

var start_position := Vector2(160, 820)


func _ready() -> void:
	print("Level 2: Campus Rush - Starting setup")

	if player == null:
		push_error("Level 2 setup error: Player node not found.")
		return

	start_position = player.global_position
	player.last_safe_position = start_position

	_setup_game_manager_state()
	_setup_hud_objective()
	_setup_exit_trigger()

	_configure_player_camera.call_deferred()
	call_deferred("_late_setup")

	print("Level 2: Campus Rush - Ready")


func _late_setup() -> void:
	_setup_game_manager_state()
	_setup_hud_objective()
	_configure_player_camera()


func _setup_game_manager_state() -> void:
	if GameManager.has_method("set_level_display_name"):
		GameManager.set_level_display_name("Level 2")
	elif "current_level_display_name" in GameManager:
		GameManager.current_level_display_name = "Level 2"

	GameManager.level_state = GameManager.LEVEL_STATE_PLAYING

	# Level 2 happens after Level 1, so Student ID should already be collected.
	GameManager.has_student_id = true

	if GameManager.time_remaining <= 0.0:
		GameManager.time_remaining = 180.0

	if GameManager.has_method("set_objective"):
		GameManager.set_objective("Reach the Faculty Building")
	elif "current_objective" in GameManager:
		GameManager.current_objective = "Reach the Faculty Building"


func _setup_hud_objective() -> void:
	if GameManager.has_method("set_objective"):
		GameManager.set_objective("Reach the Faculty Building")
	elif "current_objective" in GameManager:
		GameManager.current_objective = "Reach the Faculty Building"

	if hud == null:
		print("WARNING: HUD node not found.")
		return

	var objective_label := hud.get_node_or_null("VBoxContainer/ObjectiveLabel")
	if objective_label != null:
		objective_label.text = "Objective: Reach the Faculty Building"


func _configure_player_camera() -> void:
	if player == null:
		push_warning("Level 2 camera setup skipped: Player node not found.")
		return

	var overview_camera := get_node_or_null("LevelOverviewCamera")
	if overview_camera != null and overview_camera is Camera2D:
		overview_camera.enabled = false

	var player_camera := player.get_node_or_null("Camera2D") as Camera2D

	if player_camera == null:
		player_camera = Camera2D.new()
		player_camera.name = "Camera2D"
		player.add_child(player_camera)
		print("Created new Camera2D under Player.")

	player_camera.enabled = true
	player_camera.zoom = Vector2(0.75, 0.75)
	player_camera.offset = Vector2(0, -120)
	player_camera.limit_left = CAMERA_LIMIT_LEFT
	player_camera.limit_top = CAMERA_LIMIT_TOP
	player_camera.limit_right = CAMERA_LIMIT_RIGHT
	player_camera.limit_bottom = CAMERA_LIMIT_BOTTOM
	player_camera.position_smoothing_enabled = false
	player_camera.make_current()

	print("Level 2 player camera enabled.")


func _setup_exit_trigger() -> void:
	if faculty_exit_trigger == null:
		print("ERROR: FacultyBuildingExit trigger not found at Exits/FacultyBuildingExit.")
		return

	faculty_exit_trigger.monitoring = true
	faculty_exit_trigger.monitorable = true

	if not faculty_exit_trigger.body_entered.is_connected(_on_faculty_building_entered):
		faculty_exit_trigger.body_entered.connect(_on_faculty_building_entered)

	print("FacultyBuildingExit trigger connected.")


func _on_faculty_building_entered(body: Node2D) -> void:
	print("Faculty building exit touched by: ", body.name)

	if not _is_player(body):
		return

	if GameManager.has_method("is_level_active") and not GameManager.is_level_active():
		return

	print("Level 2 Complete! Reached the Faculty Building.")

	if GameManager.has_method("complete_current_level"):
		GameManager.complete_current_level("Level 2")
	else:
		GameManager.level_state = GameManager.LEVEL_STATE_COMPLETED
		if GameManager.has_signal("level_finished"):
			GameManager.level_finished.emit(GameManager.level_state)


func _is_player(body: Node) -> bool:
	if body == player:
		return true

	if body.name == "Player":
		return true

	if body.is_in_group("player"):
		return true

	return false