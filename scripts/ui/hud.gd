extends CanvasLayer

@onready var time_label: Label = $VBoxContainer/TimeLabel
@onready var focus_label: Label = $VBoxContainer/FocusLabel
@onready var notes_label: Label = $VBoxContainer/NotesLabel
@onready var coffee_label: Label = $VBoxContainer/CoffeeLabel
@onready var student_id_label: Label = $VBoxContainer/StudentIDLabel
@onready var objective_label: Label = $VBoxContainer/ObjectiveLabel
@onready var low_focus_label: Label = $VBoxContainer/LowFocusLabel
@onready var focus_feedback_label: Label = $VBoxContainer/FocusFeedbackLabel
@onready var result_panel: PanelContainer = $ResultPanel
@onready var result_label: Label = $ResultPanel/ResultLabel

var focus_feedback_time_remaining := 0.0


func _ready() -> void:
	GameManager.focus_changed.connect(_on_focus_changed)
	GameManager.level_finished.connect(_on_level_finished)
	result_panel.visible = false


func _process(delta: float) -> void:
	time_label.text = "Time: %d" % ceili(GameManager.time_remaining)
	focus_label.text = "Focus: %d" % GameManager.focus
	notes_label.text = "Notes: %d" % GameManager.notes_collected
	coffee_label.text = "Coffee: %d" % GameManager.coffee_collected
	student_id_label.text = "Student ID: %s" % ("Yes" if GameManager.has_student_id else "No")
	objective_label.text = "Objective: %s" % GameManager.current_objective
	low_focus_label.visible = GameManager.focus <= 40

	if focus_feedback_time_remaining > 0.0:
		focus_feedback_time_remaining = maxf(focus_feedback_time_remaining - delta, 0.0)
		focus_feedback_label.visible = focus_feedback_time_remaining > 0.0


func _on_focus_changed(amount: int, _new_focus: int) -> void:
	if amount > 0:
		focus_feedback_label.text = "Focus +%d" % amount
	else:
		focus_feedback_label.text = "Focus %d" % amount

	focus_feedback_label.visible = true
	focus_feedback_time_remaining = 1.0


func _on_level_finished(state: String) -> void:
	show_result_panel(state)


func show_result_panel(state: String) -> void:
	var student_id_text := "Yes" if GameManager.has_student_id else "No"
	var rank := GameManager.get_level_1_rank()

	if state == GameManager.LEVEL_STATE_FAILED:
		result_label.text = "Time's Up!\nMissed Exam\n\nTime Remaining: 0\nFocus: %d\nNotes Collected: %d\nCoffee Collected: %d\nStudent ID: %s\nRank: %s\n\nPress R to Restart" % [GameManager.focus, GameManager.notes_collected, GameManager.coffee_collected, student_id_text, rank]
	else:
		result_label.text = "Level 1 Complete\n\nTime Remaining: %d\nFocus: %d\nNotes Collected: %d\nCoffee Collected: %d\nStudent ID: %s\nRank: %s\n\nPress R to Restart" % [ceili(GameManager.time_remaining), GameManager.focus, GameManager.notes_collected, GameManager.coffee_collected, student_id_text, rank]

	result_panel.visible = true
