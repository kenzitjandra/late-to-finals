# PlayerController — basic 2D platformer movement for the student character.
# Attached to the Player CharacterBody2D scene.
# Handles horizontal movement, single jump, gravity, and deceleration.

extends CharacterBody2D

## Horizontal movement speed in pixels per second.
@export var speed: float = 400.0

## Upward velocity applied on jump (negative = upward in Godot 2D).
@export var jump_velocity: float = -620.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_slippery := false
var is_inside_fall_zone := false
var last_safe_position := Vector2.ZERO


func _ready() -> void:
	add_to_group("player")
	var player_camera := get_node_or_null("Camera2D") as Camera2D
	if player_camera:
		player_camera.enabled = true
		player_camera.zoom = Vector2(0.75, 0.75)
		player_camera.offset = Vector2(0, -120)
		player_camera.limit_top = -300
		player_camera.limit_right = 6000
		player_camera.limit_bottom = 2300
		player_camera.make_current()
	last_safe_position = global_position


func set_slippery_movement(enabled: bool) -> void:
	is_slippery = enabled


func set_inside_fall_zone(enabled: bool) -> void:
	is_inside_fall_zone = enabled


func respawn_to_last_safe_position() -> void:
	global_position = last_safe_position
	velocity = Vector2.ZERO
	is_slippery = false
	is_inside_fall_zone = false


func _is_standing_on_temporary_platform() -> bool:
	for index in get_slide_collision_count():
		var collision := get_slide_collision(index)
		if collision.get_collider() is Node and collision.get_collider().is_in_group("temporary_platform"):
			return true

	return false


func _physics_process(delta: float) -> void:
	if not GameManager.is_level_active():
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Accumulate gravity each frame when the player is airborne.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Jump only when standing on a surface — no double jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Read horizontal input from the Input Map (A/D or Left/Right arrows).
	var direction: float = Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		velocity.x = direction * speed
	else:
		# Wet Floor lowers stopping friction without changing normal movement.
		var deceleration := speed * (0.03 if is_slippery else 0.2)
		velocity.x = move_toward(velocity.x, 0.0, deceleration)

	move_and_slide()
	if is_on_floor() and not is_inside_fall_zone and not _is_standing_on_temporary_platform():
		last_safe_position = global_position
