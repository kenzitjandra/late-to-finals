extends Node2D

const CAMERA_LIMIT_LEFT := 0
const CAMERA_LIMIT_TOP := -1250
const CAMERA_LIMIT_RIGHT := 7800
const CAMERA_LIMIT_BOTTOM := 400

@onready var player: Node2D = get_node_or_null("Player")


func _ready() -> void:
	if "level_state" in GameManager:
		GameManager.level_state = GameManager.LEVEL_STATE_PLAYING

	_configure_player_camera.call_deferred()


func _configure_player_camera() -> void:
	if player == null:
		push_warning("Level 2 camera setup skipped: Player node not found.")
		return

	var player_camera := player.get_node_or_null("Camera2D") as Camera2D
	if player_camera == null:
		push_warning("Level 2 camera setup skipped: Player Camera2D not found.")
		return

	player_camera.enabled = true
	player_camera.zoom = Vector2(0.75, 0.75)
	player_camera.offset = Vector2(0, -120)
	player_camera.limit_left = CAMERA_LIMIT_LEFT
	player_camera.limit_top = CAMERA_LIMIT_TOP
	player_camera.limit_right = CAMERA_LIMIT_RIGHT
	player_camera.limit_bottom = CAMERA_LIMIT_BOTTOM
	player_camera.make_current()
