extends Area2D

@export var completion_label_path: NodePath = NodePath("../LevelCompleteLabel")

var triggered := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	if triggered or not GameManager.is_level_active():
		return
	triggered = true

	_show_completion_label()
	GameManager.go_to_level_2_from_level_1()
	print("Level 1 Complete!")


func _show_completion_label() -> void:
	var label := get_node_or_null(completion_label_path) as CanvasItem
	if label == null and get_parent() != null:
		label = get_parent().find_child("LevelCompleteLabel", true, false) as CanvasItem
	if label == null:
		label = find_child("LevelCompleteLabel", true, false) as CanvasItem
	if label:
		label.visible = true
