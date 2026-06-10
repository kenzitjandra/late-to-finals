extends Node

signal focus_changed(amount: int, new_focus: int)
signal level_finished(state: String)

const LEVEL_STATE_PLAYING := "playing"
const LEVEL_STATE_COMPLETED := "completed"
const LEVEL_STATE_FAILED := "failed"

# Level scene paths.
# Changed Level 2 path to the cleaned Level2_CampusRush scene.
# If your friend's Main/menu expects the old Lvl2/lvl2.tscn, tell me and we can switch it back.
const LEVEL_1_PATH := "res://scenes/levels/Level1_ApartmentPanic.tscn"
const LEVEL_2_PATH := "res://scenes/levels/Level2_CampusRush.tscn"
const LEVEL_3_PATH := "res://scenes/levels/Level3_FinalHallSprint.tscn"

var focus: int = 100
var time_remaining: float = 180.0
var notes_collected: int = 0
var coffee_collected: int = 0
var has_student_id: bool = false
var current_objective: String = "Get your Student ID"
var level_state: String = LEVEL_STATE_PLAYING

# Used by HUD result screen.
# Level managers should set this when their level starts.
var current_level_display_name: String = "Level 1"


func _process(delta: float) -> void:
	if level_state != LEVEL_STATE_PLAYING:
		if Input.is_action_just_pressed("restart"):
			restart_current_level()
		return

	if time_remaining > 0.0:
		time_remaining = maxf(time_remaining - delta, 0.0)
		if time_remaining <= 0.0:
			fail_current_level()


func reset_level_1_state() -> void:
	current_level_display_name = "Level 1"
	focus = 100
	time_remaining = 180.0
	notes_collected = 0
	coffee_collected = 0
	has_student_id = false
	current_objective = "Get your Student ID"
	level_state = LEVEL_STATE_PLAYING


func reset_for_level(level_name: String, objective: String, keep_student_id: bool = true) -> void:
	current_level_display_name = level_name
	focus = 100
	time_remaining = 180.0
	notes_collected = 0
	coffee_collected = 0
	has_student_id = keep_student_id
	current_objective = objective
	level_state = LEVEL_STATE_PLAYING


func set_level_display_name(level_name: String) -> void:
	current_level_display_name = level_name


func set_objective(text: String) -> void:
	current_objective = text


func is_level_active() -> bool:
	return level_state == LEVEL_STATE_PLAYING


func complete_current_level(level_name: String = "") -> void:
	if level_state != LEVEL_STATE_PLAYING:
		return

	if level_name != "":
		current_level_display_name = level_name

	level_state = LEVEL_STATE_COMPLETED
	level_finished.emit(level_state)


func fail_current_level(level_name: String = "") -> void:
	if level_state != LEVEL_STATE_PLAYING:
		return

	if level_name != "":
		current_level_display_name = level_name

	time_remaining = 0.0
	level_state = LEVEL_STATE_FAILED
	level_finished.emit(level_state)


func restart_current_level() -> void:
	level_state = LEVEL_STATE_PLAYING
	get_tree().reload_current_scene()


# Level transition helpers.
# These keep your friend's connected level flow.
func go_to_level_1() -> void:
	reset_level_1_state()
	get_tree().change_scene_to_file.call_deferred(LEVEL_1_PATH)


func go_to_level_2_from_level_1() -> void:
	# Level 2 happens after Level 1, so keep Student ID.
	reset_for_level("Level 2", "Reach the Faculty Building", true)
	get_tree().change_scene_to_file.call_deferred(LEVEL_2_PATH)


func go_to_level_3_from_level_2() -> void:
	# Level 3 happens after Level 1, so keep Student ID.
	reset_for_level("Level 3", "Enter the Exam Hall", true)
	get_tree().change_scene_to_file.call_deferred(LEVEL_3_PATH)


# Backward-compatible old functions.
# These allow old Level 1 code to keep working.
func complete_level_1() -> void:
	complete_current_level("Level 1")


func fail_level_1() -> void:
	fail_current_level("Level 1")


func restart_level_1() -> void:
	reset_level_1_state()
	get_tree().reload_current_scene()


func get_current_level_rank() -> String:
	if level_state == LEVEL_STATE_FAILED:
		return "Missed Exam"

	if time_remaining >= 60.0 and focus >= 70 and notes_collected >= 1 and has_student_id:
		return "Excellent"

	if time_remaining >= 30.0 and focus >= 50 and has_student_id:
		return "Good"

	if focus >= 30 or notes_collected >= 1 or has_student_id:
		return "Barely Ready"

	return "Needs Improvement"


# Backward-compatible old rank function.
func get_level_1_rank() -> String:
	return get_current_level_rank()


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