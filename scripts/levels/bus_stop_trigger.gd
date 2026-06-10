# BusStopTrigger — attached to the BusStop Area2D in Level 1.
# Detects when the player reaches the bottom-right bus stop.
# Filters by player group and collision layer to avoid false triggers.

extends Area2D

var triggered := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	# Only the player group can trigger the bus stop.
	if not body.is_in_group("player"):
		return

	if not GameManager.is_level_active():
		return

	# One-shot: fire only the first time the player arrives.
	if triggered:
		return
	triggered = true

	GameManager.complete_level_1()
	print("Level 1 Complete!")

	# Show the temporary on-screen label if it exists.
	var label := get_node_or_null("../LevelCompleteLabel")
	if label:
		label.visible = true
