extends Area2D

var triggered := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if triggered or not GameManager.is_level_active():
		return

	triggered = true
	GameManager.go_to_level_3_from_level_2()
