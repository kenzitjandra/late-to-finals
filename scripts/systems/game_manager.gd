extends Node

signal focus_changed(amount: int, new_focus: int)
signal level_finished(state: String)

const LEVEL_STATE_PLAYING := "playing"
const LEVEL_STATE_COMPLETED := "completed"
const LEVEL_STATE_FAILED := "failed"
const LEVEL_2_PATH := "res://scenes/levels/Lvl2/lvl2.tscn"

var focus: int = 100
var time_remaining: float = 180.0
var notes_collected: int = 0
var coffee_collected: int = 0
var has_student_id: bool = false
var current_objective: String = "Get your Student ID"
var level_state: String = LEVEL_STATE_PLAYING


func _process(delta: float) -> void:
	if level_state != LEVEL_STATE_PLAYING:
		if Input.is_action_just_pressed("restart"):
			restart_level_1()
		return

	if time_remaining > 0.0:
		time_remaining = maxf(time_remaining - delta, 0.0)
		if time_remaining <= 0.0:
			fail_level_1()


func reset_level_1_state() -> void:
	focus = 100
	time_remaining = 180.0
	notes_collected = 0
	coffee_collected = 0
	has_student_id = false
	current_objective = "Get your Student ID"
	level_state = LEVEL_STATE_PLAYING


func set_objective(text: String) -> void:
	current_objective = text


func is_level_active() -> bool:
	return level_state == LEVEL_STATE_PLAYING


func complete_level_1() -> void:
	if level_state != LEVEL_STATE_PLAYING:
		return

	level_state = LEVEL_STATE_COMPLETED
	level_finished.emit(level_state)


func go_to_level_2_from_level_1() -> void:
	if level_state == LEVEL_STATE_PLAYING:
		complete_level_1()

	level_state = LEVEL_STATE_PLAYING
	get_tree().change_scene_to_file.call_deferred(LEVEL_2_PATH)


func fail_level_1() -> void:
	if level_state != LEVEL_STATE_PLAYING:
		return

	time_remaining = 0.0
	level_state = LEVEL_STATE_FAILED
	level_finished.emit(level_state)


func restart_level_1() -> void:
	reset_level_1_state()
	get_tree().reload_current_scene()


func get_level_1_rank() -> String:
	if level_state == LEVEL_STATE_FAILED:
		return "Missed Exam"

	if time_remaining >= 60.0 and focus >= 70 and notes_collected >= 1 and has_student_id:
		return "Excellent"

	if time_remaining >= 30.0 and focus >= 50 and has_student_id:
		return "Good"

	if focus >= 30 or notes_collected >= 1 or has_student_id:
		return "Barely Ready"

	return "Needs Improvement"


func change_focus(amount: int) -> void:
	var old_focus := focus
	focus = clampi(focus + amount, 0, 100)
	var actual_change := focus - old_focus
	if actual_change != 0:
		focus_changed.emit(actual_change, focus)


func collect_study_note() -> void:
	notes_collected += 1


func collect_coffee() -> void:
	coffee_collected += 1
	change_focus(10)


func collect_student_id() -> void:
	has_student_id = true
