extends Area2D

@export_enum("study_note", "coffee", "student_id") var collectible_type := "study_note"

var collected := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if collected:
		return

	if not body.is_in_group("player"):
		return

	collected = true
	var level1_manager := get_tree().get_first_node_in_group("level1_manager")
	match collectible_type:
		"study_note":
			GameManager.collect_study_note()
			if level1_manager:
				level1_manager.on_study_note_collected()
		"coffee":
			GameManager.collect_coffee()
		"student_id":
			GameManager.collect_student_id()
			if level1_manager:
				level1_manager.on_student_id_collected()

	queue_free()
